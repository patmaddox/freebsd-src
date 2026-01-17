atf_test_case hello
hello_head()
{
	atf_set "descr" "hello freebsd"
}

hello_body()
{
	atf_check -o inline:"hello freebsd\n" hello
}

atf_init_test_cases()
{
	atf_add_test_case hello
}
