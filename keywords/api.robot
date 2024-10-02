*** Settings ***
Documentation       Ключевые слова для проверки API
Library             RPA.HTTP
Library             RPA.JSON
Library             Collections
Library             JsonValidator
Library             OperatingSystem
Library             String
Library             Process
Library             RPA.FileSystem
Library             libs/File.py
Library             String
Variables           variables.py



*** Keywords ***
:>Http Запрос 
    [Arguments]        ${type}    ${url}    ${headers_dict}    ${exp_status}=any    &{params}
    [Documentation]    Отправить HTTP запрос
    ...                
    ...                ${type} - тип запроса: GET, POST, PUT, DELETE\
    ...                ${url} - адрес запроса\
    ...                ${headers_dict} - словарь с заголовками HTTP запроса\
    ...                ${exp_status} - код который ожидаем в ответ на запрос. По умолчанию ANY.\
    ...                &nbsp;&nbsp;&nbsp;Шаг завершается с ошибкой если код ответа отличается от ожидаемого.\
    ...                &nbsp;&nbsp;&nbsp;Можно указать anything. Тогда шаг проходит с любым кодом ответа.\
    ...                &{params} - словарь с параметрами запроса.\
    ...                &nbsp;&nbsp;&nbsp;Можно передать в виде набора параметр=значение либо готовый словарь.
    ...                \
    ...                \
    ...                return - ответ HTTP запроса\
    ...                Так же последний ответ сохраняется в переменную ${RSP}\
    ...                Препдыдущий ответ (если он был) сохраняется в ${RSP_PREV}
    
    #Сохраняем предыдущий ответ
    ${RSP}=              Get Variable Value    ${RSP}
    ${RSP_PREV}=         Set Variable If    """${RSP}""" != 'None'    ${RSP}    'None'
    ${RSP_PREV_JSON}=    Set Variable If    """${RSP}""" != 'None'    ${RSP.json()}    'None'
    Set Test Variable    ${RSP_PREV}
    Set Test Variable    ${RSP_PREV_JSON}
    
    #Сохраняем параметры запроса для логирования 
    &{REQUEST_DICT}=    Create Dictionary    type=${type}    url=${url}    headers=${headers_dict}    params=&{params}    exp_status=${exp_status}
    Set Test Variable   ${REQUEST_DICT}

    ${type}=    Convert To Lower Case  ${type}

    IF    '${type}' == 'get'
        ${RSP}=                GET    ${url}    ${params}    headers=${headers_dict}    expected_status=${exp_status}
        Set Test Variable      ${RSP}
        Set Test Variable      ${RSP_JSON}    ${RSP.json()}
        Return From Keyword    ${RSP}

    ELSE IF    '${type}' == 'post'
        ${data}=    Set Variable    ${params}[data]
    
        #Читаем содержимое файла если data это путь к файлу
        ${is_exist} =      File Exists    ${data}
        IF    ${is_exist}
            ${data}=    Read File    ${data}
            ${passed} =    Run Keyword And Return Status    :>Convert data    ${data}

            IF    ${passed} == True
                ${data}=    :>Convert data    ${data}
            END

        END

        ${RSP}=                POST    ${url}    headers=${headers_dict}    expected_status=${exp_status}    data=${data}
        Set Test Variable      ${RSP}
        Set Test Variable      ${RSP_JSON}    ${RSP.json()}
        Return From Keyword    ${RSP}

    ELSE IF    '${type}' == 'put'

        ${data}=    Set Variable    ${params}[data]

        #Читаем содержимое файла если data это путь к файлу
        ${is_exist} =      File Exists    ${data}
        IF    ${is_exist}
            ${data}=    Read File    ${data}
            ${passed} =    Run Keyword And Return Status    :>Convert data    ${data}
            
            IF    ${passed}
                ${data}=    :>Convert data    ${data}
            END
        END
        
        ${RSP}=                PUT    ${url}    headers=${headers_dict}    expected_status=${exp_status}    data=${data}
        Set Test Variable      ${RSP}
        Set Test Variable      ${RSP_JSON}    ${RSP.json()}
        Return From Keyword    ${RSP}

    ELSE IF    '${type}' == 'delete'
    
        ${RSP}=                DELETE    ${url}    headers=${headers_dict}    expected_status=${exp_status}
        Set Test Variable      ${RSP}
        Set Test Variable      ${RSP_JSON}    ${RSP.json()}
        Return From Keyword    ${RSP}
    ELSE
        Fail    Неожиданный тип HTTP запроса: ${type}
    END


:>Convert data
    [Arguments]         ${data}
    &{obj}=     Convert string to JSON    ${data}  
    ${data}=   Convert JSON to String    ${obj} 
    Return From Keyword     ${data}


:>Проверяем JSON
    [Arguments]         ${json}    &{params}
    FOR    ${item}  IN  &{params}
        ${key}=    Set Variable    ${item}[0]
        ${val}=    Set Variable    ${item}[1]
        Should Be Equal As Strings    ${json}[${key}]    ${val}    msg=Значение переменной ${key} = ${json}[${key}] в JSON не соответствует ожидаемому ${val}
    END 


:>Ответ не содержит пустые поля
    [Arguments]         ${json}    
    FOR    ${item}  IN  @{json}
        FOR    ${element}    IN    @{item}
            ${val}=    Convert To String    ${item}[${element}] 
            Should Not Be Empty    ${val}    msg=Значение поля ${element} пустое
         
        END
    END 


:>Получаем список
    [Arguments]    ${elements}    ${response}    ${kit}    ${report}
    FOR    ${item}  IN  @{response} 
        ${id}=  Get value from JSON    ${item}   $.id
        IF    ${id} == ${kit}
            ${var2}=   Set Variable    ${item}[reports]
            FOR    ${item1}  IN  @{var2}
                ${id_rep}=  Get value from JSON    ${item1}   $.id
                IF    ${id_rep} == ${report}
                    @{names}=     Get values from JSON     ${item1}   $.${elements}\[*].name
                    Return From Keyword    @{names}  
                END
             END          
        END
    END 


:>Создаем тестовый json
    [Arguments]      ${file}    ${var1}    ${var2}
    ${stat_str}=    Convert To String    ${var1}
    ${stat}=    Replace String    ${stat_str}    '   "
    ${slices_str}=    Convert To String    ${var2}
    ${slices}=    Replace String    ${slices_str}    '   "
    ${temp}=    Read File    ${TEST_DATA}/T9_0.json
    ${temp}=    Replace String    ${temp}     TEST1        ${stat} 
    ${temp}=    Replace String    ${temp}     TEST2        ${slices} 
    RPA.FileSystem.Create File    ${file}   content=${temp}
    ...    overwrite=${True}


:>Создаем тестовый json с новым groupId
    [Arguments]      ${file_from}     ${file_to}

    ${gen}=     :>Генерируем новый groupId
    ${temp}=    Read File    ${file_from}
    ${temp}=    Replace String    ${temp}     TEST1GROUP1ID        ${gen} 


    RPA.FileSystem.Create File    ${file_to}   content=${temp}
    ...    overwrite=${True}


:>Создаем тестовые json с одинаковым groupId
    [Arguments]      ${file1}     ${file2}

    ${gen}=     :>Генерируем новый groupId
    ${temp}=    Read File    ${file1}
    ${temp}=    Replace String    ${temp}     TEST1GROUP1ID        ${gen} 
    ${file1_to}=    Get File Name    ${file1} 
    ${file1_to}=    Replace String    ${file1_to}    .json    ${EMPTY}

    RPA.FileSystem.Create File    ${TEST_DATA}/${file1_to}_0.json   content=${temp}
    ...    overwrite=${True}

    ${temp}=    Read File    ${file2}
    ${temp}=    Replace String    ${temp}     TEST1GROUP1ID        ${gen} 
    ${file2_to}=    Get File Name    ${file2} 
    ${file2_to}=    Replace String    ${file2_to}    .json    ${EMPTY}

    RPA.FileSystem.Create File    ${TEST_DATA}/${file2_to}_0.json   content=${temp}
    ...    overwrite=${True}
 

:>Генерируем новый groupId
    ${gen1}=    Generate Random String    8    [NUMBERS]eac
    ${gen2}=    Generate Random String    4    [NUMBERS]eac
    ${gen3}=    Generate Random String    4    [NUMBERS]eac
    ${gen4}=    Generate Random String    4    [NUMBERS]eac
    ${gen5}=    Generate Random String    12    [NUMBERS]eac
    
    ${gen}=     Set Variable    ${gen1}-${gen2}-${gen3}-${gen4}-${gen5}
    Return From Keyword    ${gen}


:>Удаляем demo-фильтры
    [Arguments]      ${file}    ${slices}
    ${temp}=    Read File    ${file}
    ${temp3}=    Convert To Json    ${temp}
    ${var2}=   Get value from JSON    ${temp3}    $.filters

    FOR    ${element}    IN    @{var2}
        ${variable}=    Run Keyword And Return Status    Should Contain    ${slices}    ${element}
        IF    ${variable}
            Remove Values From List    ${slices}   ${element}
        END
        Log    ${element}
        
    END
    Return From Keyword    ${slices}


:>Проверяем JSON для среза
    [Arguments]         ${response}    ${slice}    &{params}

    ${var1}=    Set Variable    0
    FOR    ${item}  IN  @{response} 
     
        ${item_slice}=  Get value from JSON    ${item}   $.[slice]
        IF    ${item_slice} == ${slice}
            ${item_stat}=  Get value from JSON    ${item}   $.[statistics]
            ${var1}=    Set Variable    ${item_slice}
            FOR    ${item}  IN  &{params}
                ${key}=    Set Variable    ${item}[0]
                ${val}=    Set Variable    ${item}[1]
                
                ${var}=    :>Обрезаем знаки после запятой    ${item_stat}[${key}]    3
                Should Be Equal As Strings    ${var}    ${val}    msg=Значение переменной ${var} в JSON не соответствует ожидаемому ${val}
            END          
        END
    END   
    IF    ${var1} == 0
        Fail    Срез не найден
    END

:>Обрезаем знаки после запятой
    [Arguments]         ${variable1}    ${end}
    ${variable}=    Convert To String    ${variable1}        
    ${var1}=    Fetch From Left    ${variable}   .
    ${var2}=    Fetch From Right    ${variable}   .
    ${var3}=    Get Substring    ${var2}    0    ${end}
    ${variable2}=    Set Variable    ${var1}.${var3}
    Return From Keyword    ${variable2}


:>Проверяем статус
    [Arguments]         ${ex_code}    ${response}=${RSP}
    Status Should Be    ${ex_code}    response=${response}    msg=Неверный HTTP статус ответа


:>Проверяем ошибку
    [Arguments]      ${response}    ${ex_code}    ${ex_error}    ${ex_message}
    Should Be Equal As Integers   ${ex_code}     ${response.json()}[code]
    Should Be Equal As Strings    ${ex_error}    ${response.json()}[errorCode]
    Should Contain                ${response.json()}[errorMessage]    ${ex_message}


:>Ответ содержит N подстрок
    [Arguments]      ${response}    ${item}    ${nstr_count}
    Should Contain X Times      '${response}'    ${item}    ${nstr_count}    msg=Значение ${item} содержится в ответе не ${nstr_count} раз


:>Ответ содержит поле
    [Arguments]      ${response}    ${item}
    FOR    ${element}    IN    @{response}
        Should Contain      ${element}    ${item}    msg=Значение ${item} не содержится в ответе
    END


:>Проверяем что в JSON-ответе есть следующие значения для канала с id     
    [Arguments]      ${id}    ${response}    @{data}
    FOR    ${item}  IN  @{response.json()}[resultBody]
        ${item_id}=  Get value from JSON    ${item}   $.slice.companyNetId
        Run Keyword If    ${item_id} == ${id}    :>Проверяем данные    ${item}     @{data}
    END 


:>Проверяем данные в ответе 
    [Arguments]      ${response}    ${id}    ${val}
    FOR    ${item}  IN  @{response}
        ${item_id}=  Get value from JSON    ${item}    $.${id}
        IF    ${item_id} == None
            Fail    Данные в ответе не найдены
        ELSE
            Should Be Equal As Numbers    ${item_id}     ${val}    msg=${id} = ${val} не найдено    
        END
        
    END


:>Проверяем данные
    [Arguments]      ${resp_item}    @{data}
    FOR  ${item2}  IN  @{data}
        @{item_list} =  Evaluate  ${item2}
        ${item_key} =     Set Variable     ${item_list}[0]
        ${item_value}=    Set Variable     ${item_list}[1]
        ${resp_value}=    Get value from JSON    ${resp_item}    $.statistics.${item_key}
        ${item_value_num}=    Convert To Number    ${item_value}    2
        ${resp_value_num}=    Convert To Number    ${resp_value}    2
        Should Be Equal As Numbers    ${item_value_num}     ${resp_value_num}    msg=Значение в ответе ${resp_value} не соответствует ${item_value}
    END


:>Проверяем схему ответа
    [Arguments]      ${resp}    ${schema_path}
    Validate jsonschema from file  ${resp}   ${schema_path}


:>Проверяем название в поле ответа
    [Arguments]      ${response}    ${name}    ${field_name}
    FOR    ${item}  IN  @{response.json()}[data]
        ${item_nm}=  Get value from JSON    ${item}   $.${field_name}
        Should Be Equal As Strings    ${name}    ${item_nm}    msg=Название в ответе ${item_nm} не соответствует ${name} 
    END    


:>Проверяем сортировку в ответе
    [Arguments]      ${response}    ${field_name}    ${orderDir}
    @{item_list} =    Create List
    

    FOR    ${item}  IN  @{response}
        ${item_nm}=  Get value from JSON    ${item}   $.${field_name}
        IF    '${field_name}' == 'id'
            ${item_nm}=    Convert To Integer    ${item_nm}
        END
        Append To List    ${item_list}    ${item_nm}
    END        

    @{item_list_sort} =    Copy List    ${item_list}     
    Sort List    ${item_list_sort}
    IF    '${orderDir}' == 'ASC'
            Lists Should Be Equal  ${item_list}      ${item_list_sort}    msg=Сортировка в ответе не соответствует ожидаемой
    ELSE
            Reverse List   ${item_list_sort} 
            Lists Should Be Equal  ${item_list}      ${item_list_sort}    msg=Сортировка в ответе не соответствует ожидаемой
    END
    @{item_list_sort2} =    Copy List    ${item_list_sort}    


:>Поле в строке равно
    [Arguments]      ${response}    ${num}    ${field_name}    ${field_expected}
    ${item_value} =     Set Variable    ${response.json()}[data][${num}][${field_name}] 
    Should Be Equal As Strings    ${item_value}   ${field_expected}    msg=Поле ${item_value} в JSON не соответствует ожидаемому ${field_expected}


:>Сравниваем строки
    [Arguments]      @{data}
    FOR  ${item}  IN  @{data}
        @{item_list} =  Evaluate  ${item}
        Should Be Equal As Strings    ${item_list}[0]    ${item_list}[1] 
    END



    
