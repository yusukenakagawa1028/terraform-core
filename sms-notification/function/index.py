import os
import re
import logging
import boto3
from email import policy
from email.parser import BytesParser

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client("s3")
sns = boto3.client("sns")

ABUSE_RE = re.compile(r"abuse", re.IGNORECASE)
# 宛先（環境変数があればそちら優先）
ALERT_PHONE_E164 = os.getenv("ALERT_PHONE_E164", "+818016217553")

def lambda_handler(event, context):
    records = event.get("Records", [])
    for r in records:
        try:
            bucket = r["s3"]["bucket"]["name"]
            key = r["s3"]["object"]["key"]

            obj = s3.get_object(Bucket=bucket, Key=key)
            raw_email = obj["Body"].read()

            msg = BytesParser(policy=policy.default).parsebytes(raw_email)
            email_subject = _safe_str(msg.get("subject"))
            email_address_from = _safe_str(msg.get("from"))
            email_address_to_mime = _safe_str(msg.get("to"))
            email_address_cc = _safe_str(msg.get("cc"))
            email_body = _extract_body_text(msg)
                
            print("subject: " + email_subject)
            print("from: " + email_address_from)
            print("to: " + email_address_to_mime)
            print("cc: " + email_address_cc)
            print("body: " + email_body)

            #   email_object = email.message_from_string(email_body)
            haystack = email_subject + "\n" + email_body

            if ABUSE_RE.search(haystack):
                print("Receive Abuse Report.")
                message = "メールを確認してください"
                response = sns.publish(
                    PhoneNumber=ALERT_PHONE_E164,
                    Message=message,
                    # 重要性の高い通知のためTransactional属性を定義
                    MessageAttributes={
                        "AWS.SNS.SMS.SMSType": {"DataType": "String", "StringValue": "Transactional"}
                    },
                )
                print(f"Message sent successfully. MessageId: {response['MessageId']} PhoneNumber:{table_data['toPhoneNumber']}")
            else:
                print("The email is not of critical security nature.")
        except Exception as e:
            print(f"Error sending message: {str(e)}")
            return {
                'statusCode': 500,
                'body': f"Error sending message: {str(e)}"
            }
        
        return {
            'statusCode': 200,
            'body': f"Check mail successfully. Subject: {email_subject} Address: {email_address_from}"
        }


def _safe_str(v) -> str:
    if v is None:
        return ""
    if isinstance(v, str):
        return v
    return str(v)


def _extract_body_text(msg) -> str:
    texts_plain = []
    texts_html = []

    if msg.is_multipart():
        for part in msg.walk():
            if part.get_content_disposition() == "attachment":
                continue

            ctype = (part.get_content_type() or "").lower()
            if ctype not in ("text/plain", "text/html"):
                continue

            try:
                payload = part.get_payload(decode=True) or b""
                charset = part.get_content_charset() or "utf-8"
                text = payload.decode(charset, errors="replace")
            except Exception:
                raw = part.get_payload(decode=True) or b""
                text = raw.decode("utf-8", errors="replace")

            if ctype == "text/plain":
                texts_plain.append(text)
            else:
                texts_html.append(text)
    else:
        ctype = (msg.get_content_type() or "").lower()
        raw = msg.get_payload(decode=True) or b""
        charset = msg.get_content_charset() or "utf-8"
        text = raw.decode(charset, errors="replace") if raw else ""
        if ctype == "text/plain":
            texts_plain.append(text)
        elif ctype == "text/html":
            texts_html.append(text)
        else:
            texts_plain.append(text)

    if texts_plain:
        return "\n".join(texts_plain)

    if texts_html:
        html = "\n".join(texts_html)
        html = re.sub(r"<[^>]+>", " ", html)
        html = re.sub(r"\s+", " ", html).strip()
        return html
    return ""


def _send_sms_alert(subject: str, bucket: str, key: str):
    # SMS は長すぎると分割され得るので、短めにまとめるのが安全です。:contentReference[oaicite:1]{index=1}
    message = f"[ALERT] abuse detected. subject='{subject[:80]}' s3://{bucket}/{key}"

    sns.publish(
        PhoneNumber=ALERT_PHONE_E164,
        Message=message,
        MessageAttributes={
            # 緊急通知用途なら Transactional が無難
            "AWS.SNS.SMS.SMSType": {"DataType": "String", "StringValue": "Transactional"}
        },
    )
    print(f"sent sms alert: {message}")
