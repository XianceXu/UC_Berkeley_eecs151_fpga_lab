# UC_Berkeley_eecs151_fpga_lab
This project is one of my berkeley course projects, we took about 2 month to finish that, with my lovely parter - Donaldo Wilson... 

Our ffnal design ended up using a total of 5 stages. Gaining insight from the 61C cpu, we
split our stages into Instruction Fetch, Instruction Decode, Execute, Memory and Writeback
stages. Our memory uses both synchronous reads and writes. To take advantage of
this register-like behavior, we place our instruction memory between the Decode and Execute
stage. We also place data memory and I/O in between our Execute and Memory stages.
Originally, our three stage cpu design could not handle any increase in clock frequency. This
is the main reason why we decided to use no forwarding to decrease our critical paths for
a 5 stage version. For the sake of simplicity, we decided to delete all forwarding paths to
maximize our frequency. After these additions, we found that our current critical path is in
our Execute stage, between our immediate generated register and memory.
