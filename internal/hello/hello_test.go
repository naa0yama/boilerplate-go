package hello

import "testing"

func TestSayHello(t *testing.T) {
	type args struct {
		name string
	}
	tests := []struct {
		name string
		args args
		want string
	}{
		{name: "Test with Alice", args: args{name: "Alice"}, want: "Hello World! Alice\n"},
		{name: "Test with empty string", args: args{name: ""}, want: "Hello World! \n"},
		{name: "Test with special characters", args: args{name: "世界"}, want: "Hello World! 世界\n"},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := SayHello(tt.args.name); got != tt.want {
				t.Errorf("SayHello() = %v, want %v", got, tt.want)
			}
		})
	}
}
