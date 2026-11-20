describe('portfolio homepage', () => {
  it('displays the portfolio owner', () => {
    cy.visit('/')
    cy.get('h1').should('have.text', 'Yassine Ouri')
  })
})
