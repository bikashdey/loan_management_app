module JsonWebToken
  SECRET_KEY = Rails.application.secrets.jwt_secret

  def self.encode(payload, exp = 1.minutes.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    body = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new(body)
  rescue JWT::ExpiredSignature => e
    raise JWT::ExpiredSignature, "Token has expired"
  rescue JWT::DecodeError => e
    raise JWT::DecodeError, "Invalid token"
  end
end
