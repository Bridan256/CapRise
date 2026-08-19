# CapRise Investment Platform

CapRise is a browser-based investment platform for account access, investment packages, wallet balances, referrals, withdrawals, and transaction history. The web platform lives in `src/wwwroot/index.html` and can be deployed to any static web host.

## Features

- **Investment Management**: Users can view, add, and remove investments easily.
- **Portfolio Overview**: A dedicated view to see overall portfolio performance and statistics.
- **User-Friendly Interface**: Intuitive design for seamless navigation and interaction.

## Project Structure

The project is organized into the following main components:

- **src**: Contains the main application code.
  - **App.xaml**: Application resources and layout.
  - **App.xaml.cs**: Application initialization and main page setup.
  - **MainPage.xaml**: Layout and UI for the main page.
  - **MainPage.xaml.cs**: Logic for the main page.
  - **Views**: Contains different views for investment and portfolio.
    - **InvestmentView.xaml**: UI for managing investments.
    - **PortfolioView.xaml**: UI for viewing portfolio performance.
  - **Models**: Defines the data structures.
    - **Investment.cs**: Represents an investment entity.
    - **Portfolio.cs**: Represents a collection of investments.
  - **Services**: Contains business logic.
    - **InvestmentService.cs**: Methods for managing investments.
  - **Resources**: Contains styles and themes.
    - **Styles.xaml**: Application-wide styles.

## Setup Instructions

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/CapRise.git
   ```
2. Navigate to the project directory:
   ```
   cd CapRise
   ```
3. Restore dependencies:
   ```
   dotnet restore
   ```
4. Build the project:
   ```
   dotnet build
   ```
5. Run the application:
   ```
   dotnet run
   ```

## Usage

Once the application is running, users can navigate through the main page to access investment management features and view their portfolio. The intuitive design ensures that users can easily find the information they need.

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue for any suggestions or improvements.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.