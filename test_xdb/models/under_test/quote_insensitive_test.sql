SELECT 
    {% for val in ('SnOwFlakE','BigQuerY','PostGRes',) %}
        {% if val|lower == target.type %}
            '{{xdb.quote_insensitive(val)}}' AS folded_not_reserved_word_camel
        {% endif %}
    {% endfor %}
    ,'{{xdb.quote_insensitive(target.type|upper)}}' AS folded_not_reserved_word_upper
    ,'{{xdb.quote_insensitive(target.type|lower)}}' AS folded_not_reserved_word_lower
    ,'{{xdb.quote_insensitive("group")}}' AS folded_reserved_word


