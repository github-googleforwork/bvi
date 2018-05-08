SELECT
  TIMESTAMP_TO_USEC(protoPayload.line.time) as time_usec,
  REGEXP_EXTRACT(log_message, "DATE=(?s)(.*) ::: RESOURCE=") AS date,
  REGEXP_EXTRACT(log_message, "RESOURCE=(?s)(.*) ::: MESSAGE_ID=") AS resource,
  REGEXP_EXTRACT(log_message, "MESSAGE_ID=(?s)(.*) ::: MESSAGE=") AS message_id,
  REGEXP_EXTRACT(log_message, "MESSAGE=(?s)(.*) ::: REGENERATE=") AS message,
  REGEXP_EXTRACT(log_message, "REGENERATE=(?s)(.*)") AS regenerate
FROM (
  SELECT
    protoPayload.line.time,
    receiveTimestamp,
    operation,
    protoPayload.line.logMessage AS log_message
  FROM
    FLATTEN((
      SELECT
        protoPayload.line.time,
        receiveTimestamp,
        operation.id AS operation,
        FIRST(SPLIT(protoPayload.resource, '?')) AS resource,
        protoPayload.line.logMessage
      FROM (TABLE_DATE_RANGE([YOUR_PROJECT_ID:logs.appengine_googleapis_com_request_log_],
            DATE_ADD(DATE(CURRENT_TIMESTAMP()),-10,"DAY"), CURRENT_TIMESTAMP())) logs
      WHERE
        protoPayload.line.logMessage CONTAINS 'BVI LOG :::' ),protopayload.line ))
ORDER BY
  protoPayload.line.time