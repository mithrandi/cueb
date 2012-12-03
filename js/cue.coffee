class Sheet extends Backbone.Model
    defaults: ->
        filename: ''
        filetype: 'WAVE'
        artist: ''
        title: ''


    initialize: ->
        @tracks = new TrackCollection


    flatten: ->
        lines = [
            "PERFORMER \"#{ @get('artist') }\"",
            "TITLE \"#{ @get('title') }\"",
            "FILE \"#{ @get('filename') }\" #{ @get('filetype') }"]
        timestamp = 0
        index = 1
        lastDuration = 0
        @tracks.each (track) =>
            result = track.flatten index, timestamp, @get('artist')
            lines = lines.concat result
            timestamp += track.getDuration()
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
        artist: ''
        hours: 0
        minutes: 0
        seconds: 0


    setDuration: (hours, minutes, seconds) ->
        @set 'duration',


    getDuration: ->
        return @get('hours') * 3600 + @get('minutes') * 60 + @get('seconds')


    flatten: (index, timestamp, sheetArtist) ->
        ["  TRACK #{ twoDigits(index) } AUDIO",
         "    TITLE \"#{ @get('title') }\"",
         "    PERFORMER \"#{ @get('artist') || sheetArtist }\"",
         "    INDEX 01 #{ formatTimestamp(timestamp) }"]



class AppView extends Backbone.View
    el: '#app'
    initialize: ->
        @sheetView = new SheetView(model: @options.sheet)


    render: ->
        @sheetView.render()
        return @



class SheetView extends Backbone.View
    el: '#app'
    template: _.template($('#sheet-template').html())
    events:
        'change #main input': 'changed'
        'click #add': 'addTrack'
        'focus #cue': 'focused'
        'change #cue': 'cueEdited'


    initialize: ->
        @model.on 'change', this.render, this
        @model.tracks.on 'add', this.trackAdded, this
        @model.tracks.on 'change', this.render, this
        @model.tracks.on 'remove', this.render, this


    render: ->
        @$('#main').html @template(@model.toJSON())
        @$('#cue').val @model.flatten()
        return @


    changed: (event) ->
        elem = event.target
        @model.set elem.id, elem.value


    focused: (event) ->
        event.target.select()


    cueEdited: (event) ->


    addTrack: ->
        @model.tracks.create()
        return false


    trackAdded: (track) ->
        view = new TrackView(model: track)
        @$('#tracks').append(view.render().el)
        @render()



class TrackCollection extends Backbone.Collection
    model: Track
    url: 'dummy'



class TrackView extends Backbone.View
    tagName: 'li'
    template: _.template($('#track-template').html())
    events:
        'change input': 'changed'
        'click .track-action-remove': 'remove'


    initialize: ->
        @model.on 'remove', this.removed, this


    render: ->
        @$el.html(@template(@model.toJSON()))
        return @


    remove: ->
        @model.destroy()


    removed: ->
        @$el.remove()


    changed: (event) ->
        elem = event.target
        @model.set elem.name, elem.value



$(document).ready ->
    Backbone.sync = ->
        return null
    window.sheet = new Sheet
    window.app = new AppView(sheet: sheet)
    window.app.render()
