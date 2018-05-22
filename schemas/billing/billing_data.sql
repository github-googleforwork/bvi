-- billing_data

SELECT
  LEFT(FORMAT_UTC_USEC(usage_start_time),10) AS base_date,
  service.description AS service.product,
  sku.description AS sku.resource_type,
  usage_start_time AS start_time,
  usage_end_time AS end_time,
  IFNULL(cost,0) AS cost,
  currency AS currency,
  currency_conversion_rate AS currency_conversion_rate,
  usage.amount AS usage.usage_amount,
  usage.unit AS usage.usage_unit
FROM (TABLE_QUERY([YOUR_PROJECT_ID:billing], 'table_id CONTAINS "gcp_billing_export"'))
WHERE
  project.id = 'YOUR_PROJECT_ID'
