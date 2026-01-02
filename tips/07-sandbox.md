# Tip: Activez le Sandbox Claude Code (Linux)

**Claude Code** recommande d'activer le **Sandbox** pour isoler l'exécution des commandes.

## Installation des dépendances

```bash
# Ubuntu/Debian
sudo apt install socat bubblewrap

# Fedora
sudo dnf install socat bubblewrap

# Arch
sudo pacman -S socat bubblewrap
```

## C'est quoi ?

| Composant | Rôle |
|-----------|------|
| `bubblewrap` | Outil de sandboxing léger (utilisé par Flatpak) |
| `socat` | Communication avec le sandbox |

## Pourquoi c'est important ?

Claude Code peut exécuter des commandes shell (`npm install`, `git`, scripts...).
Le sandbox empêche tout accès non autorisé à votre système.

| Sans Sandbox | Avec Sandbox |
|--------------|--------------|
| Commandes exécutées directement | Isolées dans un conteneur |
| Accès complet au filesystem | Accès restreint au projet |
| Risque si code malveillant | Protection garantie |

## Vérifier

Après installation, redémarrez Claude Code. Le sandbox s'active automatiquement.

> C'est une fonctionnalité de sécurité de **Claude Code**, recommandée par Anthropic.
