package realatletico

func main() {
	fcPermission, err := filter.NewCompoundFilter([]string{
		`$.person.partnership.dp_role == "credit_analyst"`,
	})
	// TODO: for dev only, need to remove vd after CA flow finished
	fcPermission.Or([]string{
		`$.person.partnership.dp_role == "vd"`,
	})
}
