# frozen_string_literal: true

json.message 'Successfully requested friendship'
json.sent_request_to do
  json.partial! '/v1/shared/user', user: passive_friend
end
