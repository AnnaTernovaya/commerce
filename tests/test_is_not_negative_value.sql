
-- Check for negative values

{% test is_even(model, column_name) %}


with validation as (

    select
        {{ column_name }} as not_negative_field

    from {{ model }}

),

validation_errors as (

   SELECT
      not_negative_field
   FROM validation
   WHERE not_negative_field < 0
)

select *
from validation_errors

{% endtest %}



