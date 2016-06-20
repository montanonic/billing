Users can bill multiple clients. It's possible though that event hours may
overlap, leading to a double billing situation. This cannot happen, so we should
have a system when creating an invoice to ensure that (1) no two events in the
invoice conflict in their times, and (2) no two invoices ever bill for the same
time (we'll have to search through their invoice history for this one).


All of this code can be implemented using Ecto queries, leveraging the speed
of Postgres.
