# Expo Style Guide (SDK 54)

*Modern Expo development with SDK 54, featuring Expo Router, EAS services, and performance optimization for 2025.*

## Table of Contents

1. [Expo Setup & Configuration](#expo-setup--configuration)
2. [Expo Router (File-Based Navigation)](#expo-router-file-based-navigation)
3. [Project Structure](#project-structure)
4. [Component Patterns](#component-patterns)
5. [Expo APIs & Services](#expo-apis--services)
6. [State Management](#state-management)
7. [Platform-Specific Code](#platform-specific-code)
8. [Styling Approaches](#styling-approaches)
9. [Testing Strategies](#testing-strategies)
10. [Accessibility](#accessibility)
11. [EAS Build & Deploy](#eas-build--deploy)
12. [Best Practices](#best-practices)

---

## Expo Setup & Configuration

### Project Creation

```bash
# Create new Expo project with SDK 54
npx create-expo-app@latest MyApp --template blank-typescript

# For Expo Router template
npx create-expo-app@latest MyApp --template tabs@54

# Install dependencies
cd MyApp
npx expo install
```

### Core Configuration (app.json)

```json
{
  "expo": {
    "name": "MyApp",
    "slug": "my-app",
    "version": "1.0.0",
    "orientation": "portrait",
    "icon": "./assets/icon.png",
    "userInterfaceStyle": "automatic",
    "splash": {
      "image": "./assets/splash.png",
      "resizeMode": "contain",
      "backgroundColor": "#ffffff"
    },
    "assetBundlePatterns": ["**/*"],
    "ios": {
      "supportsTablet": true,
      "bundleIdentifier": "com.company.myapp"
    },
    "android": {
      "adaptiveIcon": {
        "foregroundImage": "./assets/adaptive-icon.png",
        "backgroundColor": "#ffffff"
      },
      "package": "com.company.myapp"
    },
    "web": {
      "favicon": "./assets/favicon.png",
      "bundler": "metro"
    },
    "plugins": [
      "expo-router",
      [
        "expo-dev-client",
        {
          "addGeneratedScheme": false
        }
      ]
    ],
    "experiments": {
      "typedRoutes": true
    },
    "scheme": "myapp"
  }
}
```

### TypeScript Configuration

```json
{
  "extends": "expo/tsconfig.base",
  "compilerOptions": {
    "strict": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "@/components/*": ["./src/components/*"],
      "@/hooks/*": ["./src/hooks/*"],
      "@/utils/*": ["./src/utils/*"],
      "@/types/*": ["./src/types/*"]
    }
  },
  "include": [
    "**/*.ts",
    "**/*.tsx",
    ".expo/types/**/*.ts",
    "expo-env.d.ts"
  ]
}
```

---

## Expo Router (File-Based Navigation)

### Basic Setup

```bash
# Install Expo Router dependencies
npx expo install expo-router react-native-safe-area-context react-native-screens expo-linking expo-constants expo-status-bar
```

### File Structure & Routes

```
app/
├── _layout.tsx                 # Root layout
├── index.tsx                   # Home route (/)
├── profile.tsx                 # Profile route (/profile)
├── settings/
│   ├── _layout.tsx            # Settings layout
│   ├── index.tsx              # Settings home (/settings)
│   └── privacy.tsx            # Privacy settings (/settings/privacy)
├── (tabs)/
│   ├── _layout.tsx            # Tab layout
│   ├── index.tsx              # Tab home (/)
│   ├── search.tsx             # Search tab (/search)
│   └── profile.tsx            # Profile tab (/profile)
├── users/
│   └── [id].tsx               # Dynamic route (/users/:id)
└── +not-found.tsx             # 404 handler
```

### Root Layout Configuration

```typescript
// app/_layout.tsx
import { Stack } from 'expo-router';
import { useColorScheme } from 'react-native';
import { ThemeProvider, DarkTheme, DefaultTheme } from '@react-navigation/native';
import { useFonts } from 'expo-font';
import { useEffect } from 'react';
import { SplashScreen } from 'expo-splash-screen';

// Keep splash screen visible while loading
SplashScreen.preventAutoHideAsync();

export default function RootLayout() {
  const colorScheme = useColorScheme();
  
  const [loaded] = useFonts({
    Inter: require('../assets/fonts/Inter-Regular.ttf'),
  });

  useEffect(() => {
    if (loaded) {
      SplashScreen.hideAsync();
    }
  }, [loaded]);

  if (!loaded) {
    return null;
  }

  return (
    <ThemeProvider value={colorScheme === 'dark' ? DarkTheme : DefaultTheme}>
      <Stack>
        <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
        <Stack.Screen name="modal" options={{ presentation: 'modal' }} />
        <Stack.Screen name="+not-found" />
      </Stack>
    </ThemeProvider>
  );
}
```

### Tab Layout

```typescript
// app/(tabs)/_layout.tsx
import React from 'react';
import { Tabs } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { useColorScheme } from 'react-native';

export default function TabLayout() {
  const colorScheme = useColorScheme();

  return (
    <Tabs
      screenOptions={{
        tabBarActiveTintColor: colorScheme === 'dark' ? '#fff' : '#007AFF',
        headerShown: false,
      }}
    >
      <Tabs.Screen
        name="index"
        options={{
          title: 'Home',
          tabBarIcon: ({ color, focused }) => (
            <Ionicons name={focused ? 'home' : 'home-outline'} size={28} color={color} />
          ),
        }}
      />
      <Tabs.Screen
        name="search"
        options={{
          title: 'Search',
          tabBarIcon: ({ color, focused }) => (
            <Ionicons name={focused ? 'search' : 'search-outline'} size={28} color={color} />
          ),
        }}
      />
      <Tabs.Screen
        name="profile"
        options={{
          title: 'Profile',
          tabBarIcon: ({ color, focused }) => (
            <Ionicons name={focused ? 'person' : 'person-outline'} size={28} color={color} />
          ),
        }}
      />
    </Tabs>
  );
}
```

### Navigation Hooks

```typescript
// Navigation patterns with Expo Router
import { useRouter, useLocalSearchParams, useGlobalSearchParams } from 'expo-router';

// Basic navigation
const router = useRouter();
router.push('/profile');
router.replace('/login');
router.back();
router.canGoBack() && router.back();

// With parameters
router.push({ pathname: '/users/[id]', params: { id: '123' } });
router.push('/users/123?tab=posts');

// Local search params (current route)
const { id } = useLocalSearchParams<{ id: string }>();

// Global search params (all routes)
const { filter } = useGlobalSearchParams<{ filter?: string }>();
```

### Dynamic Routes

```typescript
// app/users/[id].tsx
import { Stack, useLocalSearchParams } from 'expo-router';
import { View, Text } from 'react-native';

export default function UserProfile() {
  const { id } = useLocalSearchParams<{ id: string }>();

  return (
    <>
      <Stack.Screen 
        options={{ 
          title: `User ${id}`,
          headerBackTitleVisible: false,
        }} 
      />
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
        <Text>User Profile: {id}</Text>
      </View>
    </>
  );
}
```

### Typed Routes (Experimental)

```typescript
// Enable in app.json first
// types/router.d.ts (auto-generated)
declare module 'expo-router' {
  export namespace ExpoRouter {
    export interface __routes<T extends string = string> extends Record<string, unknown> {
      StaticRoutes: `/` | `/_sitemap` | `/profile` | `/settings` | `/settings/privacy`;
      DynamicRoutes: `/users/${string}`;
      DynamicRouteTemplate: `/users/[id]`;
    }
  }
}

// Usage with type safety
import { Link } from 'expo-router';

// ✅ Type-safe
<Link href="/profile">Profile</Link>
<Link href={{ pathname: '/users/[id]', params: { id: '123' } }}>User</Link>

// ❌ TypeScript error
<Link href="/invalid-route">Won't compile</Link>
```

---

## Project Structure

### Expo Router Project Structure

```
my-expo-app/
├── app/                        # File-based routing
│   ├── _layout.tsx            # Root layout
│   ├── index.tsx              # Home screen (/)
│   ├── (tabs)/                # Route group
│   │   ├── _layout.tsx        # Tab navigator
│   │   ├── index.tsx          # Tab home
│   │   └── search.tsx         # Search tab
│   ├── users/
│   │   └── [id].tsx           # Dynamic route
│   └── +not-found.tsx         # 404 handler
├── src/
│   ├── components/            # Reusable components
│   │   ├── ui/               # Base UI components
│   │   └── forms/            # Form components
│   ├── hooks/                # Custom hooks
│   │   ├── useAuth.ts
│   │   └── useApi.ts
│   ├── services/             # API & business logic
│   │   ├── auth.ts
│   │   └── api.ts
│   ├── stores/               # State management
│   │   └── authStore.ts
│   ├── utils/                # Utilities
│   │   ├── validation.ts
│   │   └── constants.ts
│   ├── types/                # TypeScript definitions
│   │   └── api.ts
│   └── styles/               # Global styles
│       ├── colors.ts
│       └── tokens.ts
├── assets/                   # Static assets
│   ├── fonts/
│   ├── images/
│   └── icons/
├── constants/                # App constants
│   ├── Colors.ts
│   └── Layout.ts
├── app.json                  # Expo configuration
├── eas.json                  # EAS Build configuration
├── metro.config.js          # Metro bundler config
└── package.json
```

### Component Organization

```typescript
// components/Button/index.ts
export { default } from './Button';
export type { ButtonProps } from './Button.types';

// components/Button/Button.tsx
import React from 'react';
import { Pressable, Text } from 'react-native';
import { useButtonStyles } from './Button.styles';
import type { ButtonProps } from './Button.types';

const Button: React.FC<ButtonProps> = ({
  variant = 'primary',
  size = 'medium',
  children,
  onPress,
  disabled = false,
  ...props
}) => {
  const styles = useButtonStyles({ variant, size, disabled });
  
  return (
    <Pressable
      style={styles.container}
      onPress={onPress}
      disabled={disabled}
      accessibilityRole="button"
      {...props}
    >
      <Text style={styles.text}>{children}</Text>
    </Pressable>
  );
};

export default Button;
```

---

## Component Patterns

### Expo-Optimized Components

```typescript
import React, { useCallback, useMemo } from 'react';
import { FlatList, RefreshControl } from 'react-native';
import { useQuery } from '@tanstack/react-query';
import { Image } from 'expo-image';

interface UserListProps {
  category?: string;
}

const UserList: React.FC<UserListProps> = ({ category }) => {
  const { data: users, isLoading, refetch } = useQuery({
    queryKey: ['users', category],
    queryFn: () => fetchUsers(category),
  });

  // Memoize renderItem to prevent unnecessary re-renders
  const renderItem = useCallback(({ item }: { item: User }) => (
    <UserCard user={item} />
  ), []);

  const keyExtractor = useCallback((item: User) => item.id, []);

  // Memoize filtered data
  const filteredUsers = useMemo(
    () => users?.filter(user => user.status === 'active') ?? [],
    [users]
  );

  return (
    <FlatList
      data={filteredUsers}
      renderItem={renderItem}
      keyExtractor={keyExtractor}
      refreshControl={
        <RefreshControl refreshing={isLoading} onRefresh={refetch} />
      }
      // Performance optimizations
      removeClippedSubviews={true}
      maxToRenderPerBatch={10}
      windowSize={21}
      initialNumToRender={10}
      updateCellsBatchingPeriod={50}
    />
  );
};
```

### Custom Hooks Pattern

```typescript
// hooks/useExpoFeatures.ts
import { useState, useEffect } from 'react';
import * as Location from 'expo-location';
import * as Notifications from 'expo-notifications';

export const useExpoFeatures = () => {
  const [permissions, setPermissions] = useState({
    location: false,
    notifications: false,
  });

  useEffect(() => {
    checkPermissions();
  }, []);

  const checkPermissions = async () => {
    const locationStatus = await Location.getForegroundPermissionsAsync();
    const notificationStatus = await Notifications.getPermissionsAsync();
    
    setPermissions({
      location: locationStatus.status === 'granted',
      notifications: notificationStatus.status === 'granted',
    });
  };

  const requestLocationPermission = async () => {
    const { status } = await Location.requestForegroundPermissionsAsync();
    setPermissions(prev => ({ ...prev, location: status === 'granted' }));
    return status === 'granted';
  };

  const requestNotificationPermission = async () => {
    const { status } = await Notifications.requestPermissionsAsync();
    setPermissions(prev => ({ ...prev, notifications: status === 'granted' }));
    return status === 'granted';
  };

  return {
    permissions,
    requestLocationPermission,
    requestNotificationPermission,
  };
};
```

---

## Expo APIs & Services

### Authentication with Expo AuthSession

```typescript
// hooks/useAuth.ts
import { useEffect } from 'react';
import { makeRedirectUri, useAuthRequest, ResponseType } from 'expo-auth-session';
import * as WebBrowser from 'expo-web-browser';
import * as SecureStore from 'expo-secure-store';

// Complete the browser session on mobile
WebBrowser.maybeCompleteAuthSession();

const discovery = {
  authorizationEndpoint: 'https://accounts.google.com/oauth/authorize',
  tokenEndpoint: 'https://oauth2.googleapis.com/token',
};

export const useGoogleAuth = () => {
  const [request, response, promptAsync] = useAuthRequest(
    {
      responseType: ResponseType.Code,
      clientId: 'YOUR_GOOGLE_CLIENT_ID',
      scopes: ['openid', 'profile', 'email'],
      additionalParameters: {},
      redirectUri: makeRedirectUri({
        scheme: 'myapp',
        path: 'auth',
      }),
    },
    discovery
  );

  useEffect(() => {
    if (response?.type === 'success') {
      const { code } = response.params;
      exchangeCodeForToken(code);
    }
  }, [response]);

  const exchangeCodeForToken = async (code: string) => {
    try {
      const tokenResponse = await fetch('https://oauth2.googleapis.com/token', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: new URLSearchParams({
          client_id: 'YOUR_GOOGLE_CLIENT_ID',
          client_secret: 'YOUR_GOOGLE_CLIENT_SECRET',
          code,
          grant_type: 'authorization_code',
          redirect_uri: makeRedirectUri({ scheme: 'myapp', path: 'auth' }),
        }),
      });

      const tokens = await tokenResponse.json();
      await SecureStore.setItemAsync('accessToken', tokens.access_token);
      await SecureStore.setItemAsync('refreshToken', tokens.refresh_token);
    } catch (error) {
      console.error('Token exchange failed:', error);
    }
  };

  return {
    request,
    promptAsync,
    isAuthenticated: response?.type === 'success',
  };
};
```

### Camera & Image Picker

```typescript
// hooks/useImagePicker.ts
import { useState } from 'react';
import * as ImagePicker from 'expo-image-picker';
import * as MediaLibrary from 'expo-media-library';

export const useImagePicker = () => {
  const [image, setImage] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  const requestPermissions = async () => {
    const { status: cameraStatus } = await ImagePicker.requestCameraPermissionsAsync();
    const { status: mediaLibraryStatus } = await MediaLibrary.requestPermissionsAsync();
    
    return cameraStatus === 'granted' && mediaLibraryStatus === 'granted';
  };

  const pickImage = async () => {
    const hasPermission = await requestPermissions();
    if (!hasPermission) {
      alert('Camera and media library permissions are required!');
      return;
    }

    setIsLoading(true);
    try {
      const result = await ImagePicker.launchImageLibraryAsync({
        mediaTypes: ImagePicker.MediaTypeOptions.Images,
        allowsEditing: true,
        aspect: [4, 3],
        quality: 0.8,
      });

      if (!result.canceled) {
        setImage(result.assets[0].uri);
      }
    } catch (error) {
      console.error('Error picking image:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const takePhoto = async () => {
    const hasPermission = await requestPermissions();
    if (!hasPermission) return;

    setIsLoading(true);
    try {
      const result = await ImagePicker.launchCameraAsync({
        allowsEditing: true,
        aspect: [4, 3],
        quality: 0.8,
      });

      if (!result.canceled) {
        setImage(result.assets[0].uri);
        await MediaLibrary.saveToLibraryAsync(result.assets[0].uri);
      }
    } catch (error) {
      console.error('Error taking photo:', error);
    } finally {
      setIsLoading(false);
    }
  };

  return {
    image,
    pickImage,
    takePhoto,
    isLoading,
  };
};
```

### Location Services

```typescript
// hooks/useLocation.ts
import { useState, useEffect } from 'react';
import * as Location from 'expo-location';

interface LocationData {
  latitude: number;
  longitude: number;
  accuracy: number | null;
}

export const useLocation = () => {
  const [location, setLocation] = useState<LocationData | null>(null);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    getCurrentLocation();
  }, []);

  const getCurrentLocation = async () => {
    try {
      const { status } = await Location.requestForegroundPermissionsAsync();
      if (status !== 'granted') {
        setErrorMsg('Permission to access location was denied');
        setIsLoading(false);
        return;
      }

      const currentLocation = await Location.getCurrentPositionAsync({
        accuracy: Location.Accuracy.High,
      });

      setLocation({
        latitude: currentLocation.coords.latitude,
        longitude: currentLocation.coords.longitude,
        accuracy: currentLocation.coords.accuracy,
      });
    } catch (error) {
      setErrorMsg('Error getting location');
    } finally {
      setIsLoading(false);
    }
  };

  const watchLocation = async (callback: (location: LocationData) => void) => {
    const { status } = await Location.requestForegroundPermissionsAsync();
    if (status !== 'granted') return;

    return Location.watchPositionAsync(
      {
        accuracy: Location.Accuracy.High,
        timeInterval: 1000,
        distanceInterval: 1,
      },
      (position) => {
        callback({
          latitude: position.coords.latitude,
          longitude: position.coords.longitude,
          accuracy: position.coords.accuracy,
        });
      }
    );
  };

  return {
    location,
    errorMsg,
    isLoading,
    getCurrentLocation,
    watchLocation,
  };
};
```

### Push Notifications

```typescript
// services/notifications.ts
import * as Notifications from 'expo-notifications';
import * as Device from 'expo-device';
import { Platform } from 'react-native';

// Configure notification behavior
Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true,
    shouldPlaySound: true,
    shouldSetBadge: false,
  }),
});

export const registerForPushNotificationsAsync = async (): Promise<string | undefined> => {
  let token;

  if (Platform.OS === 'android') {
    await Notifications.setNotificationChannelAsync('default', {
      name: 'default',
      importance: Notifications.AndroidImportance.MAX,
      vibrationPattern: [0, 250, 250, 250],
      lightColor: '#FF231F7C',
    });
  }

  if (Device.isDevice) {
    const { status: existingStatus } = await Notifications.getPermissionsAsync();
    let finalStatus = existingStatus;
    
    if (existingStatus !== 'granted') {
      const { status } = await Notifications.requestPermissionsAsync();
      finalStatus = status;
    }
    
    if (finalStatus !== 'granted') {
      alert('Failed to get push token for push notification!');
      return;
    }
    
    token = (await Notifications.getExpoPushTokenAsync()).data;
  } else {
    alert('Must use physical device for Push Notifications');
  }

  return token;
};

export const schedulePushNotification = async (title: string, body: string, seconds: number = 2) => {
  await Notifications.scheduleNotificationAsync({
    content: {
      title,
      body,
      data: { data: 'goes here' },
    },
    trigger: { seconds },
  });
};
```

### File System & Storage

```typescript
// utils/storage.ts
import AsyncStorage from '@react-native-async-storage/async-storage';
import * as FileSystem from 'expo-file-system';
import * as SecureStore from 'expo-secure-store';

// AsyncStorage for non-sensitive data
export const storage = {
  async setItem(key: string, value: any): Promise<void> {
    try {
      const jsonValue = JSON.stringify(value);
      await AsyncStorage.setItem(key, jsonValue);
    } catch (error) {
      console.error('AsyncStorage setItem error:', error);
    }
  },

  async getItem<T>(key: string): Promise<T | null> {
    try {
      const jsonValue = await AsyncStorage.getItem(key);
      return jsonValue != null ? JSON.parse(jsonValue) : null;
    } catch (error) {
      console.error('AsyncStorage getItem error:', error);
      return null;
    }
  },

  async removeItem(key: string): Promise<void> {
    try {
      await AsyncStorage.removeItem(key);
    } catch (error) {
      console.error('AsyncStorage removeItem error:', error);
    }
  },
};

// SecureStore for sensitive data
export const secureStorage = {
  async setItem(key: string, value: string): Promise<void> {
    try {
      await SecureStore.setItemAsync(key, value);
    } catch (error) {
      console.error('SecureStore setItem error:', error);
    }
  },

  async getItem(key: string): Promise<string | null> {
    try {
      return await SecureStore.getItemAsync(key);
    } catch (error) {
      console.error('SecureStore getItem error:', error);
      return null;
    }
  },

  async deleteItem(key: string): Promise<void> {
    try {
      await SecureStore.deleteItemAsync(key);
    } catch (error) {
      console.error('SecureStore deleteItem error:', error);
    }
  },
};

// FileSystem utilities
export const fileSystem = {
  async downloadFile(url: string, filename: string): Promise<string | null> {
    try {
      const { uri } = await FileSystem.downloadAsync(
        url,
        FileSystem.documentDirectory + filename
      );
      return uri;
    } catch (error) {
      console.error('File download error:', error);
      return null;
    }
  },

  async readFile(uri: string): Promise<string | null> {
    try {
      return await FileSystem.readAsStringAsync(uri);
    } catch (error) {
      console.error('File read error:', error);
      return null;
    }
  },

  async writeFile(uri: string, content: string): Promise<boolean> {
    try {
      await FileSystem.writeAsStringAsync(uri, content);
      return true;
    } catch (error) {
      console.error('File write error:', error);
      return false;
    }
  },

  async deleteFile(uri: string): Promise<boolean> {
    try {
      await FileSystem.deleteAsync(uri);
      return true;
    } catch (error) {
      console.error('File delete error:', error);
      return false;
    }
  },
};
```

---

## State Management

### Zustand Store Pattern

```typescript
// stores/userStore.ts
import { create } from 'zustand';
import { devtools } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';

interface User {
  id: string;
  name: string;
  email: string;
}

interface UserState {
  users: User[];
  selectedUser: User | null;
  isLoading: boolean;
  
  // Actions
  fetchUsers: () => Promise<void>;
  selectUser: (user: User) => void;
  updateUser: (userId: string, updates: Partial<User>) => void;
}

export const useUserStore = create<UserState>()(
  devtools(
    immer((set, get) => ({
      users: [],
      selectedUser: null,
      isLoading: false,

      fetchUsers: async () => {
        set(state => {
          state.isLoading = true;
        });
        
        try {
          const users = await api.getUsers();
          set(state => {
            state.users = users;
            state.isLoading = false;
          });
        } catch (error) {
          set(state => {
            state.isLoading = false;
          });
        }
      },

      selectUser: (user) => set(state => {
        state.selectedUser = user;
      }),

      updateUser: (userId, updates) => set(state => {
        const index = state.users.findIndex(u => u.id === userId);
        if (index !== -1) {
          Object.assign(state.users[index], updates);
        }
      }),
    }))
  )
);
```

### React Query Integration

```typescript
// services/api/users.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

export const useUsers = () => {
  return useQuery({
    queryKey: ['users'],
    queryFn: fetchUsers,
    staleTime: 5 * 60 * 1000, // 5 minutes
    cacheTime: 10 * 60 * 1000, // 10 minutes
  });
};

export const useCreateUser = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: createUser,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
  });
};
```

---

## Platform-Specific Code

### Platform-Specific Styling

```typescript
import { Platform, StyleSheet } from 'react-native';

const styles = StyleSheet.create({
  container: {
    padding: 16,
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.25,
        shadowRadius: 3.84,
      },
      android: {
        elevation: 5,
      },
    }),
  },
  text: {
    fontSize: Platform.OS === 'ios' ? 16 : 14,
    fontFamily: Platform.select({
      ios: 'Helvetica',
      android: 'Roboto',
    }),
  },
});
```

### Platform-Specific Components

```typescript
// components/StatusBar/StatusBar.ios.tsx
import React from 'react';
import { StatusBar as RNStatusBar } from 'react-native';

const StatusBar: React.FC = () => (
  <RNStatusBar barStyle="dark-content" backgroundColor="transparent" />
);

// components/StatusBar/StatusBar.android.tsx
import React from 'react';
import { StatusBar as RNStatusBar } from 'react-native';

const StatusBar: React.FC = () => (
  <RNStatusBar barStyle="light-content" backgroundColor="#6200ea" />
);
```

### Safe Area Handling

```typescript
import { useSafeAreaInsets } from 'react-native-safe-area-context';

const ScreenWithSafeArea: React.FC = ({ children }) => {
  const insets = useSafeAreaInsets();
  
  return (
    <View 
      style={{
        flex: 1,
        paddingTop: insets.top,
        paddingBottom: insets.bottom,
        paddingLeft: insets.left,
        paddingRight: insets.right,
      }}
    >
      {children}
    </View>
  );
};
```

---

## Styling Approaches

### Expo Image and Optimized Assets

```typescript
import { Image } from 'expo-image';

const OptimizedImage: React.FC<{ source: string; style?: any }> = ({ source, style }) => (
  <Image
    source={{ uri: source }}
    style={style}
    contentFit="cover"
    transition={200}
    cachePolicy="memory-disk"
  />
);
```

### Design Tokens

```typescript
// constants/Colors.ts
export const Colors = {
  light: {
    text: '#000',
    background: '#fff',
    tint: '#007AFF',
    tabIconDefault: '#ccc',
    tabIconSelected: '#007AFF',
  },
  dark: {
    text: '#fff',
    background: '#000',
    tint: '#007AFF',
    tabIconDefault: '#ccc',
    tabIconSelected: '#007AFF',
  },
};
```

---

## Testing Strategies

### Jest Configuration

```javascript
// jest.config.js
module.exports = {
  preset: 'jest-expo',
  transformIgnorePatterns: [
    'node_modules/(?!((jest-)?react-native|@react-native(-community)?)|expo(nent)?|@expo(nent)?/.*|@expo-google-fonts/.*|react-navigation|@react-navigation/.*|@unimodules/.*|unimodules|sentry-expo|native-base|react-native-svg)'
  ],
  setupFilesAfterEnv: ['<rootDir>/jest-setup.js'],
};
```

### Testing Components

```typescript
// __tests__/components/Button.test.tsx
import React from 'react';
import { render, fireEvent } from '@testing-library/react-native';
import Button from '../../src/components/Button';

describe('Button Component', () => {
  it('renders correctly', () => {
    const { getByText } = render(
      <Button onPress={jest.fn()}>Test Button</Button>
    );
    
    expect(getByText('Test Button')).toBeTruthy();
  });

  it('handles press events', () => {
    const mockPress = jest.fn();
    const { getByText } = render(
      <Button onPress={mockPress}>Test Button</Button>
    );
    
    fireEvent.press(getByText('Test Button'));
    expect(mockPress).toHaveBeenCalledTimes(1);
  });
});
```

---

## Accessibility

### Expo Accessibility Features

```typescript
import { AccessibilityInfo } from 'react-native';

const AccessibleComponent: React.FC = () => {
  const [isScreenReaderEnabled, setIsScreenReaderEnabled] = React.useState(false);

  React.useEffect(() => {
    const subscription = AccessibilityInfo.addEventListener(
      'screenReaderChanged',
      setIsScreenReaderEnabled
    );
    
    AccessibilityInfo.isScreenReaderEnabled().then(setIsScreenReaderEnabled);
    
    return () => subscription?.remove();
  }, []);

  return (
    <View>
      <Text
        accessible={true}
        accessibilityRole="header"
        accessibilityLabel="Welcome to the app"
      >
        Welcome
      </Text>
      {isScreenReaderEnabled && (
        <Text accessibilityRole="text">Screen reader is active</Text>
      )}
    </View>
  );
};
```

---

## EAS Build & Deploy

### EAS Configuration (eas.json)

```json
{
  "cli": {
    "version": ">= 5.4.0"
  },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal",
      "ios": {
        "resourceClass": "m1-medium"
      },
      "android": {
        "buildType": "developmentBuild",
        "gradleCommand": ":app:assembleDebug"
      }
    },
    "preview": {
      "distribution": "internal",
      "ios": {
        "simulator": true,
        "resourceClass": "m1-medium"
      },
      "android": {
        "buildType": "apk"
      }
    },
    "production": {
      "ios": {
        "resourceClass": "m1-medium"
      }
    }
  },
  "submit": {
    "production": {}
  }
}
```

### Development Builds

```bash
# Install EAS CLI
npm install -g @expo/eas-cli

# Login to Expo
eas login

# Configure project
eas build:configure

# Create development build
eas build --profile development --platform all

# Install on device
eas build:run -p android
eas build:run -p ios
```

### EAS Updates (OTA)

```bash
# Setup EAS Update
eas update:configure

# Create update channel
eas channel:create staging
eas channel:create production

# Publish update to staging
eas update --branch staging --message "Bug fixes and improvements"

# Promote staging to production
eas update --branch production --message "Release v1.1.0"
```

### Metro Configuration

```javascript
// metro.config.js
const { getDefaultConfig } = require('expo/metro-config');

const config = getDefaultConfig(__dirname);

// Enable Hermes (recommended for Expo SDK 54)
config.resolver.platforms = ['native', 'web', 'ios', 'android'];

// Asset extensions
config.resolver.assetExts = [
  ...config.resolver.assetExts,
  'db',
  'mp3',
  'ttf',
  'obj',
  'png',
  'jpg'
];

// Source extensions for React Native Web
config.resolver.sourceExts = [
  ...config.resolver.sourceExts,
  'jsx',
  'js',
  'ts',
  'tsx'
];

module.exports = config;
```

### Environment Variables

```bash
# .env.local (not committed)
EXPO_PUBLIC_API_URL=https://api.myapp.com
EXPO_PUBLIC_SENTRY_DSN=your_sentry_dsn

# .env.staging
EXPO_PUBLIC_API_URL=https://staging-api.myapp.com

# .env.production
EXPO_PUBLIC_API_URL=https://api.myapp.com
```

```typescript
// app.config.ts (dynamic configuration)
import { ExpoConfig, ConfigContext } from 'expo/config';

export default ({ config }: ConfigContext): ExpoConfig => ({
  ...config,
  name: 'MyApp',
  slug: 'my-app',
  version: '1.0.0',
  extra: {
    apiUrl: process.env.EXPO_PUBLIC_API_URL,
    eas: {
      projectId: 'your-project-id',
    },
  },
  updates: {
    url: 'https://u.expo.dev/your-project-id',
  },
  runtimeVersion: {
    policy: 'sdkVersion',
  },
  plugins: [
    'expo-router',
    [
      'expo-build-properties',
      {
        ios: {
          newArchEnabled: true,
        },
        android: {
          newArchEnabled: true,
        },
      },
    ],
  ],
});
```

---

## Best Practices

### Expo SDK 54 Essentials
- Use Expo Router for file-based navigation and deep linking
- Leverage EAS Build for cloud-based builds and updates
- Enable typed routes for better TypeScript integration
- Use development builds for testing device-specific features
- Implement proper environment configuration with app.config.ts

### Performance
- Use FlatList with proper optimization props (`getItemLayout`, `removeClippedSubviews`)
- Implement memoization with React.memo and useMemo/useCallback
- Enable Hermes engine (default in Expo SDK 54)
- Use Expo Image for optimized image handling
- Implement proper lazy loading and code splitting

### Code Quality
- Use TypeScript with strict mode and path mapping
- Follow Expo's folder structure conventions
- Implement comprehensive testing with Jest and Detox
- Use Expo's built-in accessibility features
- Implement proper error boundaries and fallbacks

### Architecture
- Use Expo Router for navigation and deep linking
- Implement state management with Zustand + React Query
- Follow platform-specific design patterns
- Use Expo APIs for device features (camera, location, notifications)
- Organize components with atomic design principles

### Development Experience
- Use EAS CLI for builds, updates, and submissions
- Implement proper staging/production workflows
- Use Expo Dev Tools for debugging
- Monitor app performance with Expo Analytics
- Keep Expo SDK updated for latest features and security

### Security
- Use Expo SecureStore for sensitive data
- Implement proper authentication flows with Expo AuthSession
- Follow app store security guidelines
- Use environment variables for configuration
- Implement proper certificate management with EAS

### Deployment
- Use EAS Build for consistent, cloud-based builds
- Implement OTA updates with EAS Update
- Use proper branching strategy (development → staging → production)
- Automate app store submissions with EAS Submit
- Monitor app health and crash reports

This guide provides a comprehensive foundation for modern Expo development with SDK 54, emphasizing performance, security, and developer experience while leveraging Expo's powerful ecosystem and services.