_ = require 'underscore'

module.exports = (app) ->
  Project = app.db.model 'Project'

  app.resource 'projects'
    index: (req, res, next) ->
      Project.find {}, {}, { sort: 'name' }, (err, projects) ->
        return next err if err
        switch req.format
          when 'html'
            res.render2 'projects', projects: projects
          when 'json'
            res.json projects

    new: (req, res) ->
      res.render2 'projects/new', project: new Project

    create: (req, res, next) ->
      project = new Project req.body
      project.save (err, project) ->
        return next err if err
        res.redirect '/projects/' + project.id

    show: (req, res) ->
      res.render2 'projects/show', project: req.project

    edit: (req, res) ->
      res.render2 'projects/edit', project: req.project

    update: (req, res, next) ->
      project = req.project
      _.extend project, req.body
      project.save (err, project) ->
        return next err if err
        res.redirect '/projects/' + project.id

    load: (id, fn) ->
      Project.findById id, fn
