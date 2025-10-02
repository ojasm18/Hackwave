String routeForRole(String role) {
  switch (role.toLowerCase()) {
    case 'organizer':
      return '/organizer';
    case 'attendee':
      return '/attendee';
    case 'vendor':
      return '/vendor';
    case 'sponsor':
      return '/sponsor';
    default:
      return '/attendee';
  }
}
