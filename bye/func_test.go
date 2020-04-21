package bye

import "testing"


func TestTestable(t *testing.T) {
	res:= MyTestable()
	if res != 2 {
		t.Error("wrong answer")
	}
}
