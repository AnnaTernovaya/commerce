-- Syntax used in the project - BigQuery


-- Data qality tests are presented in two folders:
--    1. path models/staging/schema.yml - standard tests
--    2. path tests/generic - customized tests

-- Data qulity checks presented above are ensuring data accuracy,
-- including validation of data types, completeness, consistency, and adherence to business rules:

--   Check for Null Values in Primary Key Columns - ensure primary keys are not nulls
--   Check for Null Values in Foreign Key Columns - ensure foreign keys are not nulls
--   Check for Duplicate Primary Keys - ensure primary keys are not duplicated
--   Check for Relathionship - ensure all foreign key values exist in the referenced table
--   Data Type Consistency - ensure that numeric fields do not contain negative values where not applicable (e.g., price, freight_value, payment_value, etc.).
