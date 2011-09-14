module.exports =
  port: process.env.PORT || 8000
  mongo_url: 'mongodb://localhost/tractor_development'
  paths:
    public: __dirname + '/../public'
