*** Settings ***
Documentation   Admin Area
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
T10_1 Admin Area : List Model Templates (Get)
    :>Http Запрос        GET
    ...                  ${api_url}admin/model-templates
    ...                  ${HEADERS}
    :>Проверяем статус   200
    :>Проверяем схему ответа    ${RSP_JSON}    ${TEST_DATA}/S10_1.json

T10_2 Admin Area : Read Model Templates (Get)
    :>Http Запрос        GET
    ...                  ${api_url}admin/model-templates/1
    ...                  ${HEADERS}
    :>Проверяем статус   200
    :>Проверяем схему ответа    ${RSP_JSON}    ${TEST_DATA}/S10_2.json
    :>Проверяем JSON         ${RSP_JSON} 
    ...                      id=1


T10_2 Admin Area : Get Form Fields (Get)
    :>Http Запрос        GET
    ...                  ${api_url}admin/forms/meter-config
    ...                  ${HEADERS}
    :>Проверяем статус   200
    :>Проверяем JSON         ${RSP_JSON} 
    ...                      name=meter-config