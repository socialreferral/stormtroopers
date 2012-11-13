# Stormtroopers

Stormtroopers is a JRuby execution environment for background tasks using threads. It can use different backends, currently it comes with a DelayedJob (light) backend only. **NOTE: While the basic functionality works and is under test, Stormtroopers is still a Work In Progress!**

## Prerequisites

JRuby 1.7.0+ in 1.9 mode. Your code and the libraries you are using must be threadsafe. If you're running with Rails in development mode be sure that you do not run more than 1 thread at a time!

## Installation

Add this line to your application's Gemfile:

    gem 'stormtroopers'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install stormtroopers

## Usage

Stormtroopers are organized in Armies, each Army has a Factory that produces Troopers. Each Trooper runs a job inside it's own Thread (which is disposed of after job completion or failure).

Configure Stormtroopers using a config file 'config/stormtroopers.yml' and execute it using 'bundle exec stormtroopers' from the root directory of your application, here's an example that specifies workers for different DelayedJob queues:

```yaml
armies:
  - factory:
      type: :delayed_job
      queues:
        - emails
        - posts
    max_threads: 10
    name: "Comms"
  - factory:
      type: :delayed_job
      queues:
        - calculation
        - graphs
    max_threads: 5
    name: "Math"
```

The above configuration specifies two armies, each with a DelayedJob factory to produce its Troopers.

Each Army can be given a set of options:

- factory: options that are passed on to the Army's Trooper producing Factory
- max_threads: the maximum number of Troopers for this Army that may be concurrently running a job at any time
- name: the Army's name, this is used when logging

You set the Army's Factory with the factory type or class option. When using type this is translated into a builtin class, when using class you can specify the name of whatever class you like (it needs to implement the appropriate interface to be able to work of course, have a look through the source code and specs to figure out what you need to do). Besides specifying the type or class, you can also specify the Factory's name (used for logging purposes), if you don't give the Factory a name then the Army's name is propagated to the Factory. The factory options also include specific settings for the chosen backend, for DelayedJob you can specify the queues that jobs may be picked up from. If you don't specify queues then the factory will pick up jobs from all queues.

## TODO

- Daemonization
- Other backends
- Documentation

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
