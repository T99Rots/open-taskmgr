bool parseBool (String str) {
  switch(str.toLowerCase().trim()) {
    case 'yes':
      return true;
    case 'no':
      return false;
    case 'true':
      return true;
    case 'false':
      return false;
    case 'enabled':
      return true;
    case 'disabled':
      return false;
  }
}
