This example demonstrates the usage of a register layer on a mock design.

The design has an APB interface and does nothing other than accept read and write values to store in its internal registers. 
For this design, an IPXACT file is provided which can be used to generate a register model using scripts or other industry available tools.
The register model is instantiated in a separate register environment along with an adapter, predictor and an APB agent to perform transactions.
In the test library, we have also tried to explore some of the existing test sequences provided by the UVM library.

There'll be some more updates on this: 
- to demonstrate BACKDOOR writes and reads
- bit-wise functions and tasks to set and clear certain bits
