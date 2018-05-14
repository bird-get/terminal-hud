// Offer a remotely accessible shell/interpreter
// Printed text is sent to remote instead of display script
// input = from remote (http?), output = to remote (http?)
// All transmitted data is encrypted

// Uses
// - remote chat client
// - sim status tracking
// - remotely getting detailed avatar info

// 1. Rez prim, put remote-shell.lsl into it
// 2. remote-shell.lsl calls back to interpreter
// 3. interpreter stores it in memory
// 4. interpreter sends http-get to remote-shell.lsl
// 5. remote-shell.lsl executes command
// 6. remote-shell.lsl responds with results of command (and exit code etc)
// 7. interpreter handles response (prints it)

// HTTP
// o Interpreter sends http-get to remote-shell, which answers with data
// + can be accessed externally using a browser or python script
// + easy to use
// + pretty fast
// - url dies -> connection lost -> no way to re-establish connection
// - Requires URL

// e-mail
// o Interpreter sends e-mail to remote-shell, which answers with data
// - url dies -> connection lost -> no way to re-establish connection
// - Requires URL
// - Slow as hell
