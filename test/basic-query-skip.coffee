should = require("should")
request = require("supertest")

support = require('./support')
app = undefined
books = undefined

describe "odata query skip", ->
  before (done) ->
    support.ready ->
      app = support.app
      books = support.books
      done()

  it "should skip items", (done) ->
    request(app)
      .get("/odata/books")
      .expect(200)
      .expect('Content-Type', /json/)
      .end (err, res) ->
        return done(err)  if(err)
        firstBook = res.body.value[0]
        request(app)
          .get("/odata/books?$skip=1")
          .expect(200)
          .expect('Content-Type', /json/)
          .end (err, res) ->
            res.body.value[0].title.should.not.be.equal(firstBook.title)
            done()
  it "should not items when skip over count of items", (done) ->
    request(app)
      .get("/odata/books?$skip=1024")
      .expect(200)
      .expect('Content-Type', /json/)
      .end (err, res) ->
        return done(err)  if(err)
        res.body.value.length.should.be.equal(0)
        done()
  it "should ignore when skip not a number", (done) ->
    request(app)
      .get("/odata/books?$skip=not-a-number")
      .expect(200)
      .end (err, res) ->
        return done(err)  if(err)
        res.body.value.length.should.be.equal(books.length)
        done()
  it "should ignore when skip not a positive number", (done) ->
    request(app)
      .get("/odata/books?$skip=-1")
      .expect(200)
      .end (err, res) ->
        return done(err)  if(err)
        res.body.value.length.should.be.equal(books.length)
        done()
