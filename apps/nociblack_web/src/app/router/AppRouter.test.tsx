import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it } from 'vitest'
import { AppRouter } from './AppRouter'

function renderAt(path: string) {
  window.history.pushState({}, '', path)
  return render(<AppRouter />)
}

describe('AppRouter', () => {
  it('affiche l’accueil sur la route racine', () => {
    renderAt('/')

    expect(
      screen.getByRole('heading', { level: 1, name: 'NociBlacK' }),
    ).toBeInTheDocument()
  })

  it('affiche la page 404 pour une route inconnue', () => {
    renderAt('/route-inconnue')

    expect(
      screen.getByRole('heading', { level: 1, name: 'Page introuvable' }),
    ).toBeInTheDocument()
    expect(screen.getByText('404')).toBeInTheDocument()
  })

  it('permet de retourner à l’accueil depuis la page 404', async () => {
    const user = userEvent.setup()
    renderAt('/route-inconnue')

    await user.click(
      screen.getByRole('link', { name: /retour à l’accueil/i }),
    )

    expect(window.location.pathname).toBe('/')
    expect(
      screen.getByRole('heading', { level: 1, name: 'NociBlacK' }),
    ).toBeInTheDocument()
  })
})