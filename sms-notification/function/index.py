import boto3
import urllib.parse
import email
import re

s3 = boto3.client('s3')
sns = boto3.client("sns")
response = None
ABUSE_RE = re.compile(r"abuse", re.IGNORECASE)


def extract_email_addresses(encoded_string):
    email_pattern = r'<([^>]+)>'
    
    matches = re.findall(email_pattern, encoded_string)
    
    return matches


def lambda_handler(event, context):
      records = event.get("Records", [])
      processed = 0
      for r in records:
            try:
                  bucket_name = r['s3']['bucket']['name']
                  object_key = urllib.parse.unquote_plus(r['s3']['object']['key'], encoding='utf-8')

                  S3objcet = s3.get_object(Bucket=bucket_name, Key=object_key)
                  #   UTF-8に変換してしまうとメールの形式によって文字化けするためバイトで読み込む
                  raw_email = S3objcet['Body'].read()
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

                  #   email_object = email.message_from_string(email_body)
                  haystack = email_subject + "\n" + email_body

                  if ABUSE_RE.search(haystack):
                        print("Receive Abuse Report.")
                        email_addresses = extract_email_addresses(email_address_to_mime)
                        email_addresses.append('all')
                        
                        dynamodb = boto3.resource('dynamodb')
                        table = dynamodb.Table('security-mail-notice-send-address-list')

                        table_info = table.scan()
                        table = table_info['Items']

                        for email_address in email_addresses:
                              for table_data in table:
                                    if table_data['teamAddress'] == email_address and table_data['sendType'] == 'SMS':
                                          print(table_data['toPhoneNumber'])

                                          message = "AWS不正通知:メールを確認してください"
                                          response = sns.publish(
                                                PhoneNumber=table_data['toPhoneNumber'],
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
            'body': f"Message sent successfully. Subject: {email_subject} Address: {email_address_from}"
      }


# 件名・宛先抽出処理
def _safe_str(v) -> str:
    if v is None:
        return ""
    if isinstance(v, str):
        return v
    return str(v)


# 本文抽出処理
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



