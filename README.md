# Serial Protocols

Some serial protocol modules I have created. Right now I only have UART

## UART

UART is an asychronous protocol that uses 4 different states in a finite state machine: `IDLE`, `START`, `DATA` and `STOP`. Both the transmit and receive modules utilize this FSM model. 

The bit rate and clock frequency is configurable through the `uart_rx` and `uart_tx` modules.

### Transmit

- In the `IDLE` state, the UART transmission data line (`uart_txd`) is held at high voltage, in this case to '1'. The reason as to why is because there could be data breaks inbetween the voltage during transmission, so it will stay idle to '1'.

- The `START` state is triggered during `IDLE` when `uart_tx_start` signal is set high. `START` sets the transmission data line low, or to '0' to indicate the beginning phase of transmission of data. During this phase it needs to check if the `bit_duration` is equal to the `CLKS_PER_BIT` parameter to ensure it can go to the next phase, `DATA`.

- The `DATA` state is responsible for actually transmitting the data bits (`uart_tx_input`) to the UART transmission data line until it reaches the maximum amount of bits it can transmit (for example this module uses 8 bits). The `bit_idx` register keeps track of which data bit to transmit. Once it has transmitted all of the data, it moves onto the `STOP` state.

- The `STOP` state sets the UART transmission data line to high, checks the `bit_duration` until it is equal to the `CLKS_PER_BIT` and if it is go back to the `IDLE` state to repeat the process.


### Receive

- In the `IDLE` state, the receiver waits until there is a low voltage or a falling edge from the UART receive data line (`uart_rxd`) to go to the `START` phase.

- In the `START` state the `bit_duration` counts until `CLKS_PER_BIT / 2` (`CLKS_PER_BIT_HALF`). The reason as to why it gets the half of the `CLKS_PER_BIT` is to sample it, or to to get the middle of the bit to ensure that receiver is synchronized with the data being received (since there is no shared clock) as well as noise reduction (e.g. transients). Once it counts through this and the UART receive data line (`uart_rxd`) is low then move on to the `DATA` phase otherwise go to back to `IDLE` if it was an incorrect signal.

- The `DATA` phase will then mid-bit sample each of the received data (which is from the `uart_rxd`) and store them to the `uart_rx_data` register. Remember in this case it will store 8 bits, so once it received all 8 data bits it will then move onto the `STOP` phase.

- The `STOP` phase then just checks if the UART receive data line is high and if it is will go to back to `IDLE` state and also set `uart_valid` to '1' to indicate that this was valid data received. Otherwise if it was low `uart_err` will be '1' to indicate an issue with the data that was received and will go back to `IDLE`.  
