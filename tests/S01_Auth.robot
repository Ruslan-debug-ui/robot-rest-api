*** Settings ***
Documentation   Группы и проекты
Metadata        Author    Evgeniy.Ganusevich@mediascope.net

Library         RPA.HTTP
Library         RPA.FileSystem
Variables       variables.py
Resource        ../keywords/auth.robot
Resource        ../keywords/api.robot
Resource        ../keywords/logger.robot

Suite Setup     :>Suite Setup
Test Teardown   :>Logger Teardown



*** Test Cases ***
T1_1 Auth : Token request (POST)    
    ${header}=        Create Dictionary        Content-Type=application/x-www-form-urlencoded  
    ${auth_body}=       Create Dictionary    username=mediascope_api    password=p3C36dpFg%zNMkVxByqy  
    :>Http Запрос        POST
    ...                  ${api_url}auth/token
    ...                  ${header}
    ...                  data=${auth_body}
    :>Проверяем статус   200
    :>Проверяем схему ответа    ${RSP_JSON}    ${TEST_DATA}/S01_1.json
    :>Проверяем JSON         ${RSP_JSON} 
    ...                      username=mediascope_api
