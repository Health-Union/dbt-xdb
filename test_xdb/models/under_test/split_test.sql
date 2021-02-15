SELECT
    {{xdb.split("word with spaces", " ")}} AS spaces
    ,{{xdb.split("100-200-300", "-")}} AS dashes
