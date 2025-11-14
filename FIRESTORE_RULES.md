# Firestore Security Rules for Anonymous Complaints

## Important: Update Your Firestore Rules

To enable anonymous complaint filing, you **must** update your Firestore security rules in the Firebase Console.

### Steps:

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: `public-complaint-app`
3. Navigate to **Firestore Database** → **Rules** tab
4. Replace the existing rules with the following:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /complaints/{complaintId} {
      // Allow read if:
      // - User is authenticated and owns the complaint, OR
      // - User is an admin, OR
      // - Complaint is anonymous (anyone can read for transparency)
      allow read: if request.auth != null &&
        (
          request.auth.uid == resource.data.userId ||
          request.auth.token.email in ['admin@gmail.com'] ||
          resource.data.isAnonymous == true
        );

      // Allow create if:
      // - User is authenticated and creating their own complaint, OR
      // - Creating an anonymous complaint (no auth required - allows unauthenticated users)
      allow create: if 
        (
          // Authenticated user creating their own complaint
          (request.auth != null && 
           request.auth.uid == request.resource.data.userId &&
           request.resource.data.isAnonymous != true) ||
          // Anonymous complaint (no auth required) - allows unauthenticated users
          (request.auth == null &&
           request.resource.data.isAnonymous == true &&
           request.resource.data.userId == null &&
           request.resource.data.userEmail == null)
        );

      // Allow update/delete if:
      // - User owns the complaint, OR
      // - User is an admin
      allow update, delete: if request.auth != null &&
        (
          request.auth.uid == resource.data.userId ||
          request.auth.token.email in ['admin@gmail.com']
        );
    }
  }
}
```

5. Click **Publish** to save the rules

### Notes:

- **Admin Email**: Update `'admin@gmail.com'` in the rules to match your actual admin email(s)
- **Anonymous Complaints**: The rules allow unauthenticated users to create complaints marked as `isAnonymous: true`
- **Security**: Anonymous complaints cannot be updated or deleted by anyone (except admins) to maintain integrity

### Testing:

After updating the rules:
1. Try filing an anonymous complaint from the login screen
2. Verify it appears in the admin dashboard with "Anonymous" badge
3. Ensure regular authenticated complaints still work

