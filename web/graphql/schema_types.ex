defmodule Billing.Schema.Types do

  use Absinthe.Schema.Notation

  @desc "Date in `yyyy-m-d` format. Example: \"2016-6-20\"."
  scalar :date do
    parse &Timex.parse(&1, "{YYYY}-{M}-{D}")
    serialize &Timex.format!(&1, "{YYYY}-{M}-{D}")
  end

  @desc "Datetime in ISOz format."
  scalar :datetime do
    parse &Timex.parse(&1, "{ISOz}")
    serialize &Timex.format!(&1, "{ISOz}")
  end

  @desc """

  See https://developers.google.com/google-apps/calendar/v3/reference/events for
  full API explanation. We can add more fields to this object whenever.
  Currently, it only includes fields that seem obviously useful.

  `color_id` shouldn't necessarily be used to inform how we render any of their
  entries. If anything, there could be a user option to turn such a feature
  on/off, but in the meantime my instinct is that this wouldn't add to the
  design in a meaningful way.

  On another note, we can filter entries by `color_id`, so it's entirely
  possible we can make this a feature with how we associate events with a client
  profile. This might be lower-friction that keyphrases/words for some users,
  so we should definitely consider this.

  """
  object :calendar_event do
    field :html_link, :string

    field :created, :datetime
    field :updated, :datetime

    field :summary, :string
    field :description, :string
    field :location, :string
    field :color_id, :string

    field :start, :event_start
    field :end, :event_end
  end

  object :event_start do
    field :date, :date
    field :date_time, :datetime
    field :time_zone, :string
  end

  object :event_end do
    field :date, :date
    field :date_time, :datetime
    field :time_zone, :string
  end

end
