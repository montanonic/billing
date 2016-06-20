data EventsListResponse = EventsListResponse
    { elKind :: Text -- ^ Type of the collection ("calendar#events").
    , elEtag :: Text -- ^ ETag of the collection.
    , elSummary :: Text -- ^ Title of the calendar.
    , elDescription :: Maybe Text -- ^ Description of the calendar.
    , elUpdated :: UTCTime -- ^ Last modification time of the calendar (as a
        -- RFC3339 timestamp). Read-only.
    , elTimeZone :: Text -- ^ The time zone of the calendar.
    , elNextPageToken :: Maybe Text -- ^ Token used to access the next page of
        -- this result. Omitted if no further results are available, in which
        -- case nextSyncToken is provided.
    , elNextSyncToken :: Maybe Text -- ^ Token used at a later point in time to
        -- retrieve only the entries that have changed since this result was
        -- returned. Omitted if further results are available, in which case
        -- nextPageToken is provided.
    , elItems :: [Event]
    } deriving (Eq, Read, Show)
$(deriveFromJSON defaultOptions{fieldLabelModifier = unCapitalize . drop 2} ''EventsListResponse)

data EventsListQueries = EventsListQueries
    { elqMaxAttendees :: Maybe Int -- ^ max >= 1; see API reference; we force
        -- this field to equal 1 so that attendees are not included in Calendar
        -- queries, as the app currently has no use for that information.
    , elqMaxResults :: Maybe Int -- ^ defaults to 250; max value is 2500
    , elqOrderBy :: Maybe OrderBy
    , elqSearchTerms :: [ByteString] -- ^ Free text search terms to find events
        -- that match these terms in any field, except for extended properties.
        -- This field is denoted as "q" in the API reference.
    , elqSingleEvents :: Maybe Bool -- ^ whether or not to display all recurring
        -- events as individual events. We default this field to True for this
        -- app, as we're concerned with the time of events, and whether or not
        -- they recur is irrelevant except for the potential of simplifying
        -- some calculations.
    , elqTimeMax :: Maybe UTCTime
    , elqTimeMin :: Maybe UTCTime
    }

data Event = Event
    { eKind :: Text -- ^ Type of the resource ("calendar#event").
    , eEtag :: Text -- ^ ETag of the resource.
    , eId :: Text -- ^ unique event identifier
    , eHtmlLink :: Text -- ^ An absolute link to this event in the Google
        -- Calendar Web UI.
    , eCreated :: UTCTime -- ^ Creation time of the event (as a RFC3339
        -- timestamp).
    , eUpdated :: UTCTime -- ^ Last modification time of the event (as a
        -- RFC3339 timestamp).
    , eSummary :: Maybe Text -- ^ Title of the event.
    , eDescription :: Maybe Text -- ^ Description of the event.
    , eLocation :: Maybe Text -- ^ Geographic location of the event as free-form
        -- text
    , eColorId :: Maybe Text -- ^ The color of the event. This is an ID
        -- referring to an entry in the event section of the colors definition
        -- (see the colors endpoint).
    , eStart :: EventStart
    , eEnd :: EventEnd
    , eICalUID :: Text -- ^ Event unique identifier as defined in RFC5545. It is
        -- used to uniquely identify events accross calendaring systems and must
        -- be supplied when importing events via the import method.
    , eSequence :: Int
    }
