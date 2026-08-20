# CapRise - Production Deployment Guide

This guide will walk you through deploying CapRise to production using Netlify.

## Prerequisites

1. **GitHub Account** - [Create one here](https://github.com)
2. **Netlify Account** - [Sign up here](https://netlify.com)
3. **Supabase Project** - Already configured (Project ID: `cptlygpmhshrvluhhgss`)
4. **Git** - [Download and install](https://git-scm.com/download/win)

## Deployment Steps

### Step 1: Install Git (Windows)

1. Download from https://git-scm.com/download/win
2. Run the installer with default settings
3. Restart your terminal/VS Code

### Step 2: Initialize Git & Push to GitHub

```powershell
# Navigate to your project
cd "c:\Users\CHETU CAFE\Desktop\New folder\CapRise"

# Initialize Git repository
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial CapRise deployment"

# Add remote (replace YOUR_USERNAME and REPO_NAME)
git remote add origin https://github.com/YOUR_USERNAME/CapRise.git

# Push to GitHub
git branch -M main
git push -u origin main
```

**Note:** Before running the `git push` command:
1. Create a new repository on GitHub (https://github.com/new)
2. Name it `CapRise`
3. Don't initialize with README, .gitignore, or license
4. Copy the HTTPS URL and replace it in the command above

### Step 3: Create .gitignore

Create a `.gitignore` file in the root directory to exclude unnecessary files:

```
# Build output
bin/
obj/
*.dll
*.exe

# IDE
.vs/
.vscode/
*.user
*.suo

# OS
.DS_Store
Thumbs.db

# Dependencies
node_modules/
packages/

# Environment
.env
.env.local
```

### Step 4: Deploy to Netlify

#### Option A: Netlify Dashboard (Easiest)

1. Go to https://app.netlify.com
2. Click "Add new site" → "Connect to Git"
3. Select GitHub and authorize
4. Choose your `CapRise` repository
5. Configure build settings:
   - **Build command:** (leave empty - this is a static site)
   - **Publish directory:** `src/wwwroot`
6. Click "Deploy site"

#### Option B: Netlify CLI

```powershell
# Install Netlify CLI
npm install -g netlify-cli

# Authenticate with Netlify
netlify login

# Deploy the site
netlify deploy --prod --dir="src/wwwroot"
```

### Step 5: Verify Deployment

After deployment, Netlify will provide you with:
- Default URL: `https://[your-site-name].netlify.app`
- Netlify Dashboard for managing deployments

### Step 6: Custom Domain (Optional)

1. In Netlify Dashboard, go to "Domain settings"
2. Click "Add custom domain"
3. Enter your domain name
4. Follow Netlify's DNS configuration instructions
5. Update your domain registrar's DNS settings

### Step 7: Verify Supabase Configuration

The application uses these Supabase credentials (already in index.html):

```javascript
const supabaseClient = window.supabase.createClient(
  'https://cptlygpmhshrvluhhgss.supabase.co',
  'sb_publishable_1AhEXwgjVQG2GodPsWTceQ_Xh4Qv5KM'
);
```

#### Apply Database Schema

1. Go to Supabase Dashboard: https://supabase.com/dashboard
2. Select your project: `cptlygpmhshrvluhhgss`
3. Go to **SQL Editor**
4. Create a new query and run the SQL from `supabase/schema.sql`

This creates the required tables:
- `profiles` - User profiles with roles
- `payment_requests` - Payment submissions for admin approval

### Step 8: Test Payment Flow

1. Visit your deployed site
2. Register a test account
3. Navigate to "Packages" and select a package
4. Submit a test payment with:
   - Provider: MTN or Airtel
   - Phone: (use any number starting with 07)
   - Reference: TEST123
5. As admin (worldbridan3@gmail.com), approve the payment in the Admin panel

## Post-Deployment Configuration

### Admin Access

The application automatically detects admins by email address. To add admins:

1. Edit the `adminEmails` array in `src/wwwroot/index.html`:
   ```javascript
   const adminEmails = ['worldbridan3@gmail.com', 'your-admin@email.com'];
   ```
2. Redeploy to production

### Environment Variables (if needed)

To use environment variables, create a `netlify.toml` file (already exists):

```toml
[build]
  publish = "src/wwwroot"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

[build.environment]
  # Add environment variables here if needed
  # SUPABASE_URL = "your-url"
```

## Troubleshooting

### Issue: Page shows 404 after deployment
- **Solution:** Ensure `netlify.toml` has the redirect rule configured
- All routes should redirect to `/index.html` for client-side routing

### Issue: Supabase authentication not working
- **Solution:** Verify your Supabase project is public/has correct permissions
- Check the published key is correct in index.html

### Issue: Payments not processing
- **Solution:** Verify payment_requests table is created in Supabase
- Check that admin user has the correct role in profiles table

### Issue: Custom domain not working
- **Solution:** Wait 24-48 hours for DNS propagation
- Verify DNS settings in your domain registrar match Netlify's requirements

## Live Monitoring

### Check Deployment Status
- Netlify Dashboard: https://app.netlify.com
- View build logs if deployment fails
- Monitor site performance in Analytics

### Monitor Supabase
- Database: https://supabase.com/dashboard
- Check for payment requests in real-time
- Monitor authentication logs

## Next Steps

After going live:

1. **Add HTTPS:** Netlify provides free SSL/TLS certificates automatically
2. **Enable CDN:** Netlify's global CDN is automatic
3. **Set up Analytics:** Enable in Netlify Dashboard
4. **Monitor Errors:** Set up error logging for production
5. **Plan Scaling:** As users grow, consider:
   - Upgrading Supabase plan
   - Adding payment gateway integration (Stripe, PayPal)
   - Setting up email notifications

## Support

- Netlify Docs: https://docs.netlify.com
- Supabase Docs: https://supabase.com/docs
- GitHub Help: https://docs.github.com

---

**Your Current Project Structure:**
```
CapRise/
├── src/
│   ├── wwwroot/          ← Published to Netlify
│   │   └── index.html    ← Main application
│   ├── Models/
│   ├── Services/
│   ├── Views/
│   └── Resources/
├── supabase/
│   └── schema.sql        ← Database schema
├── netlify.toml          ← Deployment config
└── CapRise.csproj
```

---

**Last Updated:** 2026-08-20
**Status:** Ready for Production Deployment
