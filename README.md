# VarSight

VarSight is a Flutter application designed to provide comprehensive insights into genetic variants (SNPs) by integrating data from various biological databases and generating AI-powered summaries.

## Features

*   **SNP Search:** Search for genetic variants by their rsID.
*   **AI Summary:** Get concise, AI-generated summaries of complex genetic information.
*   **Literature Review:** Access relevant PubMed articles associated with the SNP.
*   **Data Sources:** View detailed information from ClinVar and GWAS Catalog.
*   **User Authentication:** Secure user registration, login, and password management.
*   **Theming:** Supports both light and dark themes.
*   **Recent Searches:** Keeps track of your recent SNP searches for quick access.
*   **Favourites:** Save important SNP dossiers for future reference.

## Technologies Used

*   **Flutter:** UI Toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.
*   **Riverpod:** A robust and scalable state management solution for Flutter.
*   **Supabase:** Backend-as-a-Service for authentication, database (PostgreSQL), and storage.
*   **`flutter_dotenv`:** For managing environment variables.
*   **`http`:** For making HTTP requests to the backend API.
*   **`shared_preferences`:** For local data storage (e.g., recent searches, theme settings).
*   **`image_picker`:** For picking images from the gallery.
*   **`permission_handler`:** For managing platform permissions.
*   **`connectivity_plus`:** For checking network connectivity.
*   **`url_launcher`:** For launching URLs.
*   **`iconsax`:** For a rich set of icons.
*   **`google_fonts`:** For custom fonts.

## Backend

The VarSight backend is a Python FastAPI application responsible for orchestrating data retrieval from various external biological databases and generating AI-powered summaries.

### Backend Technologies

*   **FastAPI:** A modern, fast (high-performance) web framework for building APIs with Python 3.7+ based on standard Python type hints.
*   **`httpx`:** A fully featured HTTP client for Python 3, providing sync and async APIs.
*   **`groq`:** Client library for interacting with Groq's language models.
*   **`python-dotenv`:** For loading environment variables from a `.env` file.
*   **`uvicorn`:** An ASGI web server for Python.

### Backend Data Sources

*   **NCBI Variation Services:** For fetching detailed SNP data (rsID, gene, clinical significance, phenotypes).
*   **PubMed:** For searching and retrieving scientific literature (articles) related to SNPs.
*   **GWAS Catalog:** For accessing genome-wide association study data and significant traits.
*   **Groq API:** For generating AI summaries of the synthesized genetic information.

### Backend Structure

```
backend/
├── main.py             # Main FastAPI application, orchestrates data flow
├── ncbi_client.py      # Client for NCBI Variation Services
├── pubmed_client.py    # Client for PubMed E-utilities
├── gwas_client.py      # Client for GWAS Catalog API
├── llm_client.py       # Client for interacting with Groq LLM
├── utils.py            # Utility functions (e.g., clinical significance prioritization)
├── requirements.txt    # Python dependencies
└── .env                # Environment variables (e.g., API keys, backend host/port)
```

## Getting Started

### Prerequisites

*   Flutter SDK installed. ([Installation Guide](https://flutter.dev/docs/get-started/install))
*   A Supabase project set up with a `users` table and `profile-images` storage bucket.
*   Python 3.8+ installed.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/varsight.git
    cd varsight
    ```

2.  **Install Flutter dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Set up frontend environment variables:**
    Create a `.env` file in the root of the *frontend* project and add the following:
    ```
    SUPABASE_URL=YOUR_SUPABASE_URL
    SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
    ```
    Replace `YOUR_SUPABASE_URL`, and `YOUR_SUPABASE_ANON_KEY` with your actual values.


4.  **Run the Flutter application:**
    Open a new terminal, navigate back to the root of the project (`cd ..`), and run:
    ```bash
    flutter run
    ```

## Frontend Project Structure

```
varsight/
├── lib/
│   ├── config/             # Application-wide configurations (routes, themes, storage service)
│   ├── core/               # Core utilities, constants, and services
│   │   ├── constants/      # App-wide constants (colors, sizes)
│   │   ├── services/       # Core services (network)
│   │   └── utils/          # General utility functions (error handling, helpers, local storage, validators)
│   ├── features/           # Feature-specific modules
│   │   ├── authentication/ # User authentication (login, registration, profile management)
│   │   │   ├── notifiers/
│   │   │   ├── presentations/
│   │   │   ├── providers/
│   │   │   └── repositories/
│   │   ├── personalization/ # User personalization (profile editing, theme settings)
│   │   │   ├── models/
│   │   │   ├── notifiers/
│   │   │   ├── presentations/
│   │   │   ├── providers/
│   │   │   └── repositories/
│   │   └── snp_search/     # SNP search functionality
│   │       ├── models/
│   │       ├── notifiers/
│   │       ├── presentations/
│   │       ├── providers/
│   │       └── repositories/
│   ├── main.dart           # Main application entry point
│   └── main_nav.dart       # Bottom navigation bar setup
├── assets/                 # Application assets (images, text files)
├── android/                # Android specific files
├── ios/                    # iOS specific files
├── web/                    # Web specific files
├── .env                    # Frontend environment variables (ignored by Git)
└── pubspec.yaml            # Project dependencies and metadata
```

## Contributing

Contributions are welcome! Please feel free to open issues or submit pull requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
