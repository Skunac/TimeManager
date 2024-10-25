import { Capacitor } from '@capacitor/core'

export const usePlatform = () => {
    const isMobile = Capacitor.isNativePlatform()
    const platform = Capacitor.getPlatform()

    return {
        isMobile,
        platform,
        isAndroid: platform === 'android',
        isIOS: platform === 'ios',
        isWeb: platform === 'web'
    }
}