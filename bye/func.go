package bye

import (
	"fmt"
	"net/http"
)

func TestBye(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "bye")
}

func MyTestable()int {
	return 3
}