# Krath


Authorization library inspired by AWS IAM and ORY Access Control Policies.

Requires postgres and uses Ecto 3.0

## Installation

1. Add package
2. Define config
```

config :krath, repo: MyApp.Repo
```
3. Generate migration and run `Krath.Migration`

## Usage


```elixir
policy = %{
  subjects: ["max", "peter", "<zac|ken>"],
  resources: [
    "myrn:some.domain.com:resource:123",
    "myrn:some.domain.com:resource:345",
    "myrn:something:foo:.+"
  ],
  actions: ["<create|delete>", "get"],
  effect: "allow"
}
Krath.add_policy(policy)

Krath.access?("peter", "myrn:some.domain.com:resource:123", "delete") => true
Krath.access?("foobar", "myrn:some.domain.com:resource:123", "delete") => false
```



## TODO:

  - support variables
  - look into Cachex for better performance
  - support capabilities
