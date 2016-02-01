Topics = new Mongo.Collection('topics')
Comments = new Mongo.Collection('comments')

if Meteor.isServer
    Meteor.publish 'topics', ->
        Topics.find()
    Meteor.publish 'comments', ->
        Comments.find()

if Meteor.isClient
    Meteor.subscribe('topics')
    Meteor.subscribe('comments')

    Template.body.events
        'submit .new-topic': (event) ->
            event.preventDefault()
            
            title = event.target.title.value
            text = event.target.text.value

            Meteor.call('addTopic', title, text)

            event.target.title.value = ''
            event.target.text.value = ''

    Template.body.helpers
        topics: ->
            Topics.find({}, {sort: {timestamp: -1}})

    Template.topic.events
        'click .reply': (event) ->
            event.preventDefault()
            
            Meteor.call('toggleReplyForm', this._id,
                        not this.replyFormVisible)

        'submit .submit-reply': (event) ->
            event.preventDefault()

            text = event.target.text.value

            Meteor.call('addComment', this._id, text)

            event.target.text.value = ''
            Meteor.call('toggleReplyForm', this._id,
                        not this.replyFormVisible)

        'click .delete': (event) ->
            event.preventDefault()
            Meteor.call('deleteTopic', this._id)

    Template.topic.helpers
        comments: ->
            Comments.find({topic: this._id})

        countComments: ->
            Comments.find({topic: this._id}).count()

        isAuthor: ->
            this.user is Meteor.userId()

        replyFormVisible: ->
            this.replyFormVisible

    Template.comment.events
        'click .delete': (event) ->
            event.preventDefault()
            Meteor.call('deleteComment', this._id)

    Template.comment.helpers
        isAuthor: ->
            this.user is Meteor.userId()

    Accounts.ui.config
        passwordSignupFields: 'USERNAME_ONLY'

Meteor.methods
    addTopic: (title, text) ->
        Topics.insert
            user: Meteor.userId()
            username: Meteor.user().username
            timestamp: new Date()
            title: title,
            text: text

    addComment: (topicId, text) ->
        Comments.insert
            user: Meteor.userId()
            username: Meteor.user().username
            timestamp: new Date()
            topic: topicId
            text: text
    
    deleteTopic: (topicId) ->
        Topics.remove({_id: topicId, user: Meteor.userId()})
        Comments.remove({topic: topicId})

    deleteComment: (commentId) ->
        Comments.remove({_id: commentId, user: Meteor.userId()})

    toggleReplyForm: (topicId, replyFormVisible) ->
        Topics.update topicId, {
            $set: {replyFormVisible: replyFormVisible}
        }
