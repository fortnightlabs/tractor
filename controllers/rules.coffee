_ = require 'underscore'

module.exports = (app) ->
  Rule = app.db.model 'Rule'
  Project = app.db.model 'Project'

  # middleware
  loadRuleCount = (req, res, next) ->
    Rule.count {},(err, count) ->
      return next err if err
      req.ruleCount = count
      next()

  loadProjects = (req, res, next) ->
    Project.find {}, {}, (err, projects) ->
      return next err if err
      req.projects = projects
      next()

  app.param 'ruleId', (req, res, next, id) ->
    Rule.findById id, (err, rule) ->
      return next err if err
      return next 404 unless rule?
      req.rule = rule
      next()

  app.get '/rules/new', [loadProjects, loadRuleCount], (req, res, next) ->
    res.render2 'rules/new', rule: new Rule(priority: req.ruleCount), projects: req.projects, priorities: [0..req.ruleCount]

  app.get '/rules/:ruleId/edit', [loadProjects, loadRuleCount], (req, res, next) ->
    res.render2 'rules/edit', rule: req.rule, projects: req.projects, priorities: [0...req.ruleCount]

  app.post '/rules/:ruleId/run', (req, res, next) ->
    req.rule.apply projectId: null, (err, result) ->
      res.next err if err
      res.redirect '/rules'

  app.resource 'rules'
    index: (req, res, next) ->
      Rule.find().sort('priority', 'ascending').populate('project').run (err, rules) ->
        return next err if err
        res.render2 'rules', rules: rules

    create: (req, res, next) ->
      rule = new Rule req.body
      rule.save (err, rule) ->
        return next err if err
        res.redirect '/rules'

    update: (req, res, next) ->
      rule = req.rule
      _.extend rule, req.body
      # TODO update the priorities of all the other rules
      rule.save (err, rule) ->
        return next err if err
        res.redirect '/rules'

    destroy: (req, res, next) ->
      req.rule.remove (err) ->
        return next err if err
        res.redirect '/rules'

    load: (id, fn) ->
      Rule.findById id, fn
