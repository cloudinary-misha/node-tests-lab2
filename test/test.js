var assert = require('assert');
describe('Array', function() {
  describe('#indexOf()', function() {
    it('should return -1 when the value is not present', function() {
      assert.equal([1,2,3].indexOf(4), -1);
    });
  });
});


describe('Environement settings', function() {
  describe('#Environment variables are set', function() {

    if(process.env.TRAVIS_BRANCH.indexOf('master')>-1){
      it('it should check CLOUDINARY_URL for MASTER', function() {
        assert.equal(process.env.CLOUDINARY_URL, "prod");
      });
    }
    
    if(process.env.TRAVIS_BRANCH.indexOf('staging_branch')>-1){
      it('it should check CLOUDINARY_URL for STAGING', function() {
        assert.equal(process.env.CLOUDINARY_URL, "cloudinary://123123123123:kjbaskdjaksdj@misha");
      });
    }
  });
});

