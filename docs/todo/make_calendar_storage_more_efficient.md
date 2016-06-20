Currently we use `|> Enum.each(&Repo.insert/1)`, however, we should be using
`Repo.insert_many`, I just haven't figured out how to make that work properly
yet.
