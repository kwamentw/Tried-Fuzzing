## Invariant Testing / Stateful Testing suite

**This is a project aimed to increase my knowledge in invariant fuzzing**

## Usage
* navigate to the project's test directory
* Install project dependencies by following the forge instructions below
* Run any of the invariant functions/test in the test file by using the `forge test` instruction 
### Dependencies
`forge install`

### Build
To build the project run this in current directory 
```shell
$ forge build
```

### Test
To run a test, make sure you're in the current project's directory, you want to test. Then you run the shell command below + the test name 
```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Deploy
No deploy scripts in this project 

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Help
To know more about forge 

```shell
$ forge --help
```
