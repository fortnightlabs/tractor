module.exports =
  port: process.env.PORT || 8000
  mongo_url: 'mongodb://localhost/tractor_development'
  paths:
    root: __dirname + '/..'
    public: __dirname + '/../public'
    lib: __dirname + '/../lib'
