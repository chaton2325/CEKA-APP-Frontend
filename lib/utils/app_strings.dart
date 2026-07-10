import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';

class AppStrings {
  static const Map<String, Map<AppLanguage, String>> _values = {
    'home': {AppLanguage.fr: 'Accueil', AppLanguage.en: 'Home'},
    'alerts': {AppLanguage.fr: 'Alertes', AppLanguage.en: 'Alerts'},
    'profile': {AppLanguage.fr: 'Profil', AppLanguage.en: 'Profile'},
    'ticket': {AppLanguage.fr: 'Billet', AppLanguage.en: 'Ticket'},
    'communityFeed': {
      AppLanguage.fr: 'Fil communautaire',
      AppLanguage.en: 'Community feed',
    },
    'feedSubtitle': {
      AppLanguage.fr: 'Actualités, médias et conversations CEKA',
      AppLanguage.en: 'CEKA news, media and conversations',
    },
    'language': {AppLanguage.fr: 'Langue', AppLanguage.en: 'Language'},
    'cekaLogo': {
      AppLanguage.fr: 'Logo CEKA 2026',
      AppLanguage.en: 'CEKA 2026 logo',
    },
    'french': {AppLanguage.fr: 'Français', AppLanguage.en: 'French'},
    'english': {AppLanguage.fr: 'Anglais', AppLanguage.en: 'English'},
    'logout': {AppLanguage.fr: 'Déconnexion', AppLanguage.en: 'Logout'},
    'likeAction': {AppLanguage.fr: "J'aime", AppLanguage.en: 'Like'},
    'commentAction': {AppLanguage.fr: 'Commenter', AppLanguage.en: 'Comment'},
    'shareAction': {AppLanguage.fr: 'Partager', AppLanguage.en: 'Share'},
    'edit': {AppLanguage.fr: 'Modifier', AppLanguage.en: 'Edit'},
    'delete': {AppLanguage.fr: 'Supprimer', AppLanguage.en: 'Delete'},
    'cancel': {AppLanguage.fr: 'Annuler', AppLanguage.en: 'Cancel'},
    'deletePost': {
      AppLanguage.fr: 'Supprimer le post',
      AppLanguage.en: 'Delete post',
    },
    'deletePostConfirm': {
      AppLanguage.fr: 'Êtes-vous sûr de vouloir supprimer ce post ?',
      AppLanguage.en: 'Are you sure you want to delete this post?',
    },
    'deletePostError': {
      AppLanguage.fr: 'Erreur lors de la suppression du post',
      AppLanguage.en: 'Could not delete this post',
    },
    'userNotFound': {
      AppLanguage.fr: 'Utilisateur non trouvé',
      AppLanguage.en: 'User not found',
    },
    'postNotFound': {
      AppLanguage.fr: 'Post non trouvé',
      AppLanguage.en: 'Post not found',
    },
    'details': {AppLanguage.fr: 'Détails', AppLanguage.en: 'Details'},
    'video': {AppLanguage.fr: 'Vidéo', AppLanguage.en: 'Video'},
    'audio': {AppLanguage.fr: 'Audio', AppLanguage.en: 'Audio'},
    'viewAllComments': {
      AppLanguage.fr: 'Voir tous les commentaires',
      AppLanguage.en: 'View all comments',
    },
    'addBio': {
      AppLanguage.fr: 'Ajouter une biographie',
      AppLanguage.en: 'Add a bio',
    },
    'joinedIn': {AppLanguage.fr: 'Rejoint en', AppLanguage.en: 'Joined in'},
    'unknownJoinDate': {
      AppLanguage.fr: 'Date d’inscription inconnue',
      AppLanguage.en: 'Unknown join date',
    },
    'myPosts': {AppLanguage.fr: 'Mes publications', AppLanguage.en: 'My posts'},
    'posts': {AppLanguage.fr: 'Publications', AppLanguage.en: 'Posts'},
    'likes': {AppLanguage.fr: 'Likes', AppLanguage.en: 'Likes'},
    'noPostsYet': {
      AppLanguage.fr: 'Aucune publication pour le moment',
      AppLanguage.en: 'No posts yet',
    },
    'notifications': {
      AppLanguage.fr: 'Notifications',
      AppLanguage.en: 'Notifications',
    },
    'markAllRead': {
      AppLanguage.fr: 'Tout lire',
      AppLanguage.en: 'Mark all read',
    },
    'noNotifications': {
      AppLanguage.fr: 'Aucune notification pour le moment',
      AppLanguage.en: 'No notifications yet',
    },
    'notifPostComment': {
      AppLanguage.fr: ' a commenté votre post.',
      AppLanguage.en: ' commented on your post.',
    },
    'notifCommentReply': {
      AppLanguage.fr: ' a répondu à votre commentaire.',
      AppLanguage.en: ' replied to your comment.',
    },
    'notifPostLike': {
      AppLanguage.fr: ' a aimé votre post.',
      AppLanguage.en: ' liked your post.',
    },
    'notifCommentLike': {
      AppLanguage.fr: ' a aimé votre commentaire.',
      AppLanguage.en: ' liked your comment.',
    },
    'notifInteraction': {
      AppLanguage.fr: ' a interagi avec vous.',
      AppLanguage.en: ' interacted with you.',
    },
    'welcomeBack': {
      AppLanguage.fr: 'Bon retour',
      AppLanguage.en: 'Welcome Back',
    },
    'loginSubtitle': {
      AppLanguage.fr: 'Connectez-vous pour continuer',
      AppLanguage.en: 'Sign in to continue your adventure',
    },
    'email': {AppLanguage.fr: 'Email', AppLanguage.en: 'Email'},
    'password': {AppLanguage.fr: 'Mot de passe', AppLanguage.en: 'Password'},
    'enterEmail': {
      AppLanguage.fr: 'Entrez votre email',
      AppLanguage.en: 'Please enter your email',
    },
    'enterPassword': {
      AppLanguage.fr: 'Entrez votre mot de passe',
      AppLanguage.en: 'Please enter your password',
    },
    'forgotPassword': {
      AppLanguage.fr: 'Mot de passe oublié ?',
      AppLanguage.en: 'Forgot Password?',
    },
    'login': {AppLanguage.fr: 'Connexion', AppLanguage.en: 'Login'},
    'invalidCredentials': {
      AppLanguage.fr: 'Identifiants invalides',
      AppLanguage.en: 'Invalid credentials',
    },
    'noAccount': {
      AppLanguage.fr: 'Pas encore de compte ?',
      AppLanguage.en: 'Don’t have an account?',
    },
    'register': {AppLanguage.fr: 'Inscription', AppLanguage.en: 'Register'},
    'joinCeka': {AppLanguage.fr: 'Rejoindre CEKA', AppLanguage.en: 'Join CEKA'},
    'createAccount': {
      AppLanguage.fr: 'Créer un compte',
      AppLanguage.en: 'Create Account',
    },
    'registerSubtitle': {
      AppLanguage.fr: 'Commencez votre parcours avec nous',
      AppLanguage.en: 'Start your journey with us today',
    },
    'username': {
      AppLanguage.fr: 'Nom d’utilisateur',
      AppLanguage.en: 'Username',
    },
    'enterUsername': {
      AppLanguage.fr: 'Entrez un nom d’utilisateur',
      AppLanguage.en: 'Please enter a username',
    },
    'passwordMin': {
      AppLanguage.fr: 'Le mot de passe doit contenir au moins 8 caractères',
      AppLanguage.en: 'Password must be at least 8 characters',
    },
    'registrationFailed': {
      AppLanguage.fr: 'Inscription échouée',
      AppLanguage.en: 'Registration failed',
    },
    'alreadyAccount': {
      AppLanguage.fr: 'Vous avez déjà un compte ?',
      AppLanguage.en: 'Already have an account?',
    },
    'buyTicket': {
      AppLanguage.fr: 'Acheter Billet CEKA 2026',
      AppLanguage.en: 'Buy CEKA 2026 Ticket',
    },
    'forgotPasswordTitle': {
      AppLanguage.fr: 'Mot de passe oublié',
      AppLanguage.en: 'Forgot Password',
    },
    'forgotPasswordHelp': {
      AppLanguage.fr: 'Entrez votre email pour recevoir un code.',
      AppLanguage.en: 'Enter your email to receive a reset code.',
    },
    'sendCode': {
      AppLanguage.fr: 'Envoyer le code',
      AppLanguage.en: 'Send Code',
    },
    'sendCodeFailed': {
      AppLanguage.fr: 'Impossible d’envoyer le code',
      AppLanguage.en: 'Failed to send reset code',
    },
    'resetPassword': {
      AppLanguage.fr: 'Réinitialiser le mot de passe',
      AppLanguage.en: 'Reset Password',
    },
    'resetCode': {
      AppLanguage.fr: 'Code de réinitialisation',
      AppLanguage.en: 'Reset Code',
    },
    'newPassword': {
      AppLanguage.fr: 'Nouveau mot de passe',
      AppLanguage.en: 'New Password',
    },
    'resetSentTo': {
      AppLanguage.fr: 'Code envoyé à',
      AppLanguage.en: 'Reset code sent to',
    },
    'passwordResetSuccess': {
      AppLanguage.fr: 'Mot de passe réinitialisé',
      AppLanguage.en: 'Password reset successfully',
    },
    'passwordResetFailed': {
      AppLanguage.fr: 'Impossible de réinitialiser le mot de passe',
      AppLanguage.en: 'Failed to reset password',
    },
    'editProfile': {
      AppLanguage.fr: 'Modifier le profil',
      AppLanguage.en: 'Edit Profile',
    },
    'profilePhoto': {
      AppLanguage.fr: 'Photo de profil',
      AppLanguage.en: 'Profile Photo',
    },
    'bannerPhoto': {
      AppLanguage.fr: 'Photo de couverture',
      AppLanguage.en: 'Banner Photo',
    },
    'bio': {AppLanguage.fr: 'Bio', AppLanguage.en: 'Bio'},
    'updateFailed': {
      AppLanguage.fr: 'Mise à jour échouée',
      AppLanguage.en: 'Update failed',
    },
    'takePhoto': {
      AppLanguage.fr: 'Prendre une photo',
      AppLanguage.en: 'Take a photo',
    },
    'chooseFromGallery': {
      AppLanguage.fr: 'Choisir dans la galerie',
      AppLanguage.en: 'Choose from gallery',
    },
    'newPublication': {
      AppLanguage.fr: 'Nouvelle publication',
      AppLanguage.en: 'New Publication',
    },
    'post': {AppLanguage.fr: 'Publier', AppLanguage.en: 'Post'},
    'createPostFailed': {
      AppLanguage.fr: 'Impossible de créer la publication',
      AppLanguage.en: 'Failed to create post',
    },
    'shareSomething': {
      AppLanguage.fr: 'Partagez quelque chose d’inspirant...',
      AppLanguage.en: 'Share something inspiring...',
    },
    'media': {AppLanguage.fr: 'Média', AppLanguage.en: 'Media'},
    'editPost': {
      AppLanguage.fr: 'Modifier le post',
      AppLanguage.en: 'Edit post',
    },
    'save': {AppLanguage.fr: 'Enregistrer', AppLanguage.en: 'Save'},
    'updatePostFailed': {
      AppLanguage.fr: 'Impossible de modifier le post',
      AppLanguage.en: 'Failed to update post',
    },
    'editYourText': {
      AppLanguage.fr: 'Modifier votre texte...',
      AppLanguage.en: 'Edit your text...',
    },
    'currentMediaKept': {
      AppLanguage.fr: 'Médias actuels (seront conservés) :',
      AppLanguage.en: 'Current media (will be kept):',
    },
    'replaceExistingMedia': {
      AppLanguage.fr: 'Remplacer tous les médias existants',
      AppLanguage.en: 'Replace all existing media',
    },
    'newMediaToAdd': {
      AppLanguage.fr: 'Nouveaux médias à ajouter :',
      AppLanguage.en: 'New media to add:',
    },
    'accountActions': {AppLanguage.fr: 'Compte', AppLanguage.en: 'Account'},
    'deleteAccount': {
      AppLanguage.fr: 'Supprimer le compte',
      AppLanguage.en: 'Delete account',
    },
    'deleteAccountTitle': {
      AppLanguage.fr: 'Supprimer votre compte',
      AppLanguage.en: 'Delete your account',
    },
    'deleteAccountMessage': {
      AppLanguage.fr:
          'Cette action supprime immediatement votre compte et vos contenus lies. Entrez votre mot de passe pour confirmer.',
      AppLanguage.en:
          'This immediately deletes your account and related content. Enter your password to confirm.',
    },
    'currentPassword': {
      AppLanguage.fr: 'Mot de passe actuel',
      AppLanguage.en: 'Current password',
    },
    'deleteAccountSuccess': {
      AppLanguage.fr: 'Compte supprime',
      AppLanguage.en: 'Account deleted',
    },
    'deleteAccountFailed': {
      AppLanguage.fr: 'Impossible de supprimer le compte',
      AppLanguage.en: 'Could not delete account',
    },
    'invalidCurrentPassword': {
      AppLanguage.fr: 'Mot de passe actuel invalide',
      AppLanguage.en: 'Invalid current password',
    },
    'requestDataDeletion': {
      AppLanguage.fr: 'Demander la suppression des donnees',
      AppLanguage.en: 'Request data deletion',
    },
    'requestDataDeletionTitle': {
      AppLanguage.fr: 'Demande de suppression des donnees',
      AppLanguage.en: 'Data deletion request',
    },
    'requestDataDeletionMessage': {
      AppLanguage.fr:
          'Cette demande sera traitee manuellement. Elle ne supprime pas votre compte immediatement.',
      AppLanguage.en:
          'This request will be handled manually. It does not delete your account immediately.',
    },
    'reason': {AppLanguage.fr: 'Raison', AppLanguage.en: 'Reason'},
    'sendRequest': {
      AppLanguage.fr: 'Envoyer la demande',
      AppLanguage.en: 'Send request',
    },
    'dataDeletionRequestSent': {
      AppLanguage.fr: 'Demande envoyee',
      AppLanguage.en: 'Request sent',
    },
    'dataDeletionRequestFailed': {
      AppLanguage.fr: 'Impossible d envoyer la demande',
      AppLanguage.en: 'Could not send request',
    },
  };

  static String of(BuildContext context, String key) {
    final language = Provider.of<LanguageProvider>(
      context,
      listen: false,
    ).language;
    return _values[key]?[language] ?? _values[key]?[AppLanguage.fr] ?? key;
  }
}

extension AppStringsContext on BuildContext {
  String tr(String key) => AppStrings.of(this, key);
}
