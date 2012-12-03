class Sheet extends Backbone.Model
    defaults: ->
        filename: ''
        filetype: 'WAVE'
        artist: ''
        title: ''


    constructor: ->
        super()
        @tracks = new TrackCollection


    flatten: ->
        lines = [
            "PERFORMER \"#{ @get('artist') }\"",
            "TITLE \"#{ @get('title') }\"",
            "FILE \"#{ @get('filename') }\" #{ @get('filetype') }"]
        timestamp = 0
        index = 1
        lastDuration = 0
        for track in @get('tracks')
            result = track.flatten index, timestamp, @get('artist')
            lines = lines.concat result
            timestamp += track.duration
            index += 1
        return lines.join '\n'



twoDigits = (index) ->
    (if index < 10 then '0' else '') + index


divMod = (n, r) ->
    [Math.floor(n / r), n % r]


formatTimestamp = (timestamp) ->
    [minutes, timestamp] = divMod(timestamp, 60)
    seconds = Math.floor timestamp
    frames = Math.floor((timestamp - seconds) * 75)
    return twoDigits(minutes) + ':' + twoDigits(seconds) + ':' + twoDigits(frames)


class Track extends Backbone.Model
    defaults:
        title: ''
        artist: null
        duration: 0


    flatten: (index, timestamp, sheetArtist) ->
        ["  TRACK #{ twoDigits(index) } AUDIO",
         "    TITLE #{ @get('title') } \"",
         "    PERFORMER \"#{ @get('artist') ? sheetArtist }\"",
         "    INDEX 01 #{ formatTimestamp(timestamp) }"]



class AppView extends Backbone.View
    constructor: (@el, @sheet) ->
        super()
        @sheetView = new SheetView(model: @sheet)
        @$el.append(@sheetView.render().el)


    render: ->
        @sheetView.render()
        return @



class SheetView extends Backbone.View
    tagName: 'div'
    template: _.template($('#sheet-template').html())
    events:
        'change #main input': 'changed'
        'click #add': 'addTrack'

    initialize: ->
        @model.tracks.on 'add', this.trackAdded, this


    render: ->
        @$el.html(@template(@model.toJSON()))
        return @


    changed: (event) ->
        elem = event.target
        @model.set elem.id, elem.value


    addTrack: ->
        @model.tracks.create()
        return false


    trackAdded: (track) ->
        view = new TrackView(model: track)
        @$('#tracks').append(view.render().el)



class TrackCollection extends Backbone.Collection
    model: Track



class TrackView extends Backbone.View
    tagName: 'li'
    template: _.template($('#track-template').html())

    initialize: ->
        @model.on 'remove', this.remove, this

    render: ->
        @$el.html(@template(@model.toJSON()))
        return @

    remove: ->
        @$el.remove()



$(document).ready ->
    window.sheet = new Sheet
    window.app = new AppView($('#app'), sheet)
    window.app.render()
