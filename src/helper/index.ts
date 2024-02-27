export const meetPasswordRequirements = (password: string): boolean => {
  // Password must be at least 8 characters long, with at least one letter and one number
  const regex = /^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$/;
  return regex.test(password);
}