package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

var i int

func handler(w http.ResponseWriter, r *http.Request) {
	name, err := os.Hostname()
	if err != nil {
		panic(err)
	}

	i++
	fmt.Fprintf(w, "Version: 1     Response from: %s     Counter: %v \r\n", name, i)
	fmt.Fprintf(os.Stdout, "%v \r\n", r)
}

func main() {
	fmt.Fprintf(os.Stdout, "Server is listening on port 80\r\n")
	http.HandleFunc("/", handler)
	log.Fatal(http.ListenAndServe(":80", nil))
}
