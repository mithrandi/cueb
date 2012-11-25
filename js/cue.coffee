class Sheet
    filename: ''
    filetype: 'WAVE'
    artist: ''
    name: ''


    constructor: ->
        @tracks = []


    flatten: ->
        lines = [
            'PERFORMER "' + @artist + '"',
            'TITLE "' + @name + '"',
            'FILE "' + @filename + '" ' + @filetype]
        timestamp = 0
        index = 1
        lastDuration = 0
        for track in @tracks
            result = track.flatten index, timestamp, @artist
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


class Track
    title: ''
    artist: null
    duration: 0

    flatten: (index, timestamp, sheetArtist) ->
        ['  TRACK ' + twoDigits(index) + ' AUDIO',
         '    TITLE "' + @title + '"',
         '    PERFORMER "' + (@artist ? sheetArtist) + '"',
         '    INDEX 01 ' + formatTimestamp(timestamp)]



sheet = new Sheet
sheet.filename = 'mix.flac'
sheet.artist = 'Black Sun Empire'
sheet.name = 'From The Shadows (Continuous Mix)'
track = new Track
track.title = 'Rido - Exoplanet (Original Mix)'
track.duration = 166
sheet.tracks.push track
track = new Track
track.title = 'Black Sun Empire feat. Inne Eysermans - Killing The Light'
track.duration = 110
sheet.tracks.push track
print sheet.flatten()
