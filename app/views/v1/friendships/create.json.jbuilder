# frozen_string_literal: true

json.message 'Successfully requested friendship'
json.sent_request_to do
  json.partial! '/v1/shared/user', user: passive_friend
  json.partial! '/v1/shared/relationship_info', user: passive_friend
end
