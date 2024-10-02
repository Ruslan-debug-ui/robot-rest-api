*** Settings ***
Documentation       Ключевые слова для связи с сервером авторизации
Library             RPA.HTTP
Library             Collections
Library             OperatingSystem
Library    String
Variables           ../variables/auth.py

*** Keywords ***

:>Suite Setup
    ${aut_headers}=     Create Dictionary    Content-Type=application/x-www-form-urlencoded
    ${auth_body}=       Create Dictionary    username=${AUTH_USERNAME}    password=${AUTH_PASS}
    ${response}=        POST    ${AUTH_URL}    headers=${aut_headers}    data=${auth_body}
    ${bearer_token}=    Set Variable    ${response.json()}[access_token]
    Set Suite Variable  ${bearer_token}
    ${TOKEN}=           Set Variable    Bearer ${bearer_token}
    Set Suite Variable  ${TOKEN}
    ${HEADERS}=         Create Dictionary    Authorization=${TOKEN}    Content-Type=application/json
    Set Suite Variable  ${HEADERS}
    ${HEADERS_JSON}=    Create Dictionary    Content-Type=application/json    Authorization=${TOKEN}
    Set Suite Variable  ${HEADERS_JSON}


 #   ${api_url_ci}=         Get Environment Variable    CI_API_URL    ${API_URL}

 #   ${api_url}=      Set Variable       ${api_url_ci}v1
 #   ${api_url_v2}=      Set Variable       ${api_url_ci}v2

#    ${wss_url}=      Replace String    ${api_url_ci}    https://    wss://
 #   ${wss_url}=      Replace String    ${wss_url}    /api/    /api-ws/v1/group-state    

  #  Set Suite Variable  ${api_url}
  #  Set Suite Variable  ${api_url_v2}
  #  Set Suite Variable  ${wss_url}

:>Suite Setup with limits
    ${aut_headers}=     Create Dictionary    Content-Type=application/x-www-form-urlencoded
    ${auth_body}=       Create Dictionary    client_id=${AUTH_ID}    client_secret=${AUTH_SECRET}    username=${AUTH_USERNAME_LIM}    password=${AUTH_PASS_LIM}    grant_type=password
    ${response}=        POST    ${AUTH_URL}    headers=${aut_headers}    data=${auth_body}
    ${bearer_token}=    Set Variable    ${response.json()}[access_token]
    Set Suite Variable  ${bearer_token}
    ${TOKEN}=           Set Variable    Bearer ${bearer_token}
    Set Suite Variable  ${TOKEN}
    ${HEADERS}=         Create Dictionary    Authorization=${TOKEN}    Content-Type=application/json
    Set Suite Variable  ${HEADERS}
    ${HEADERS_JSON}=    Create Dictionary    Content-Type=application/json    Authorization=${TOKEN}
    Set Suite Variable  ${HEADERS_JSON}

    ${api_url_ci}=         Get Environment Variable    CI_API_URL    ${API_URL}

    ${api_url}=      Set Variable       ${api_url_ci}v1
    ${api_url_v2}=      Set Variable       ${api_url_ci}v2
    
    Set Suite Variable  ${api_url}
    Set Suite Variable  ${api_url_v2}    